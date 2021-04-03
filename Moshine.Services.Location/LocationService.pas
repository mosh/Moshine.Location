﻿namespace Moshine.Services.Location;

uses
  CoreLocation,
  Moshine.Services.Location.Interfaces,
  Moshine.Services.Location.Models,
  Moshine.Services.Location.ViewModels,
  Moshine.Api.Location,
  Moshine.Api.Location.Models,
  RemObjects.Elements.RTL;

type

  TrackDelegate = public block (value:TrackViewModel);
  ReceivedLocationDelegate = public block(value:Location);

  [Cocoa]
  LocationService = public class(ICLLocationManagerDelegate)
  private

    property Storage:IStorage;

    property workerQueue:NSOperationQueue;

    class property geoCoder:CLGeocoder := new CLGeocoder;
    property locationManager:CLLocationManager := new CLLocationManager;

    method locationManager(manager: CLLocationManager) didVisit(visit: CLVisit);
    begin

      var location := new CLLocation withLatitude(visit.coordinate.latitude) longitude(visit.coordinate.longitude);

      geoCoder.reverseGeocodeLocation(location)
        begin
          if (assigned(placemarks))then
          begin
            var place:CLPlacemark := placemarks.First;
            var description := $'{place.name}';

            receivedVisit(visit) WithDescription(description);

          end;

        end;

    end;


    method receivedVisit(visit:CLVisit) WithDescription(description:String);
    begin

      var newLocation := new Location;

      newLocation.Id := Guid.NewGuid.ToString;
      newLocation.ArrivalDate := visit.arrivalDate;
      newLocation.DepartureDate := visit.departureDate;
      newLocation.Description := description;
      newLocation.Latitude := visit.coordinate.latitude;
      newLocation.Longitude := visit.coordinate.longitude;


      if (addPosition(newLocation.Latitude, newLocation.Longitude))then
      begin
        if(assigned(ReceivedLocation))then
        begin
          ReceivedLocation(newLocation);
        end;
      end
      else
      begin
        if(assigned(AdhocLocation))then
        begin
          AdhocLocation(newLocation);
        end;
      end;


    end;

    method locationManager(manager: CLLocationManager) didFailWithError(error: NSError);
    begin

    end;

    method locationManager(manager: CLLocationManager) didUpdateLocations(locations: NSArray<CLLocation>);
    begin

    end;

    method initialize;
    begin
      workerQueue := new NSOperationQueue;

      locationManager.requestAlwaysAuthorization;
      locationManager.startMonitoringVisits;
      locationManager.delegate := self;

      locationManager.distanceFilter := 35; // 0
      locationManager.allowsBackgroundLocationUpdates := true; // 1
      locationManager.startUpdatingLocation;  // 2

    end;

  public

    // Called when a location has been added to a track
    property ReceivedLocation:ReceivedLocationDelegate;
    // Called whenever there is no active track
    property AdhocLocation:ReceivedLocationDelegate;


    {$IFDEF MACOS}
    constructor withFile(url:NSURL);
    begin
      Storage := new LocationStorage withUrl(url);
      initialize;
    end;
    {$ELSE}
    constructor;
    begin
      Storage := new LocationStorage;
      initialize;
    end;
    {$ENDIF}

    method startTrack:String;
    begin
      exit Storage.startTrack;
    end;

    method stopTrack:String;
    begin
      exit Storage.stopTrack;
    end;

    property Tracking:Boolean read
      begin
        exit assigned(ActiveTrack);
      end;


    property ActiveTrack:Track
      read
        begin
          exit Storage.ActiveTrack;
        end;


    method trackInformation(trackId:String): tuple of (Start:DateTime, Stopped:DateTime, Distance:Double);
    begin
      var allTrackLocations := Storage.positions(trackId).ToList;

      if(allTrackLocations.Count >= 2)then
      begin
        var start := allTrackLocations.First.Now;
        var stopped := allTrackLocations[allTrackLocations.Count -1].Now;

        var distance:Double := 0;

        for x:Integer := 1 to allTrackLocations.Count -1 do
        begin
          var previous := allTrackLocations[x-1];
          var current := allTrackLocations[x];

          var difference := previous.Location.GreatCircleDistance(current.Location);

          distance := distance + difference;

        end;

        exit (start, stopped, distance);


      end;

      exit (nil, nil, 0);

    end;

    method trackStats:tuple of (Boolean, Integer);
    begin
      exit Storage.trackStats;
    end;

    method addPosition(latitude:Double; longitude:Double):Boolean;
    begin
      exit Storage.addPosition(latitude, longitude);
    end;

    method positions(trackId:String):sequence of PositionViewModel;
    begin
      exit Storage.positions(trackId);
    end;

    method tracks:sequence of TrackViewModel;
    begin
      exit Storage.tracks;
    end;

    method tracks(updatesDelegate:TrackDelegate):sequence of TrackViewModel;
    begin

      var sortedTracks := Storage.tracks;

      var outerExecutionBlock: NSBlockOperation := NSBlockOperation.blockOperationWithBlock
        begin

          for each model in sortedTracks do
          begin

            var information := trackInformation(model.Id);

            if(assigned(information.Item1))then
            begin

              model.Stopped := information.Stopped;
              model.Distance := information.Distance;

              NSOperationQueue.mainQueue.addOperationWithBlock
                begin
                  updatesDelegate(model);
                end;

            end;

          end;

        end;

      workerQueue.addOperation(outerExecutionBlock);


      exit sortedTracks;

    end;


    method didVisitLocation(visit:CLVisit);
    begin
      locationManager(self.locationManager) didVisit(visit);
    end;

    method removeAllLocal;
    begin
      Storage.removeAllLocal;
    end;

    method requestLocation;
    begin

      var status := self.locationManager.authorizationStatus;

      self.locationManager.requestLocation;
    end;



  end;

end.