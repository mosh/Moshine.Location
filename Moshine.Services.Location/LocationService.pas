namespace Moshine.Services.Location;

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
  ReceivedPositionDelegate = public block(value:CLLocationCoordinate2D);

  [Cocoa]
  LocationService = public class(ICLLocationManagerDelegate)
  private

    property Last:LastLocation := new LastLocation;

    property Storage:IStorage;

    property workerQueue:NSOperationQueue;

    class property geoCoder:CLGeocoder := new CLGeocoder;
    property locationManager:CLLocationManager := new CLLocationManager;

    method CoveredDistance(locations: NSArray<CLLocation>):Boolean;
    begin
      {$IFDEF TOFFEE}
      if Last.Coordinate.Valid then
      begin
        var currentLocation := locations.First.coordinate;

        var distance := Last.Coordinate.GreatCircleDistance(currentLocation);
        if(distance <= 2)then
        begin
          exit false;
        end;
      end;
      {$ENDIF}
      exit true;
    end;

    method locationManager(manager: CLLocationManager) didChangeAuthorizationStatus(status: CLAuthorizationStatus);
    begin
      if (status = CLAuthorizationStatus.Authorized) then
      begin
        manager.startUpdatingLocation;
      end;
    end;

    method locationManager(manager: CLLocationManager) didFailWithError(error: NSError);
    begin

    end;

    method locationManager(manager: CLLocationManager) didUpdateLocations(locations: NSArray<CLLocation>);
    begin

      if(not CoveredDistance(locations))then
      begin
        exit;
      end;

      Last.Coordinate := locations.First.coordinate;

      if(Tracking)then
      begin

        for each location in locations do
        begin
          var newLocation := new Location;

          newLocation.Id := Guid.NewGuid.ToString;
          newLocation.ArrivalDate := DateTime.UtcNow;
          newLocation.DepartureDate := DateTime.UtcNow;
          newLocation.Description := '';
          newLocation.Latitude := location.coordinate.latitude;
          newLocation.Longitude := location.coordinate.longitude;

          if (addPosition(newLocation.Latitude, newLocation.Longitude))then
          begin
            if(assigned(ReceivedLocation))then
            begin
              ReceivedLocation(newLocation);
            end;
          end;
        end;
      end
      else if assigned(AdhocPosition) then
      begin
        AdhocPosition(Last.Coordinate);
      end;

    end;

    method initialize;
    begin
      workerQueue := new NSOperationQueue;

      locationManager.requestAlwaysAuthorization;
      locationManager.delegate := self;

      locationManager.distanceFilter := kCLDistanceFilterNone; // default
      locationManager.allowsBackgroundLocationUpdates := true;
      //locationManager.startUpdatingLocation;

    end;

  public

    // Called when a location has been added to a track
    property ReceivedLocation:ReceivedLocationDelegate;

    property AdhocPosition:ReceivedPositionDelegate;


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
      if not LocationEnabled.Item1 then
      begin
        exit ''
      end;

      exit Storage.startTrack;
    end;

    method stopTrack:String;
    begin
      if not Tracking then
      begin
        exit '';
      end;
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


    method trackInformation(trackId:String): tuple of (Start:DateTime, Stopped:DateTime, Distance:Double, Count:Integer);
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

        exit (start, stopped, distance, allTrackLocations.Count);


      end;

      exit (nil, nil, 0,0);

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
              model.Locations := information.Count;

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


    method didUpdateLocations(location:CLLocation);
    begin
      var locations := new NSMutableArray<CLLocation>;
      locations.addObject(location);
      locationManager(self.locationManager) didUpdateLocations(locations);
    end;

    method removeAllLocal;
    begin
      Storage.removeAllLocal;
    end;

    method requestLocation;
    begin
      if (CLLocationCoordinate2DIsValid(Last.Coordinate) and assigned(AdhocPosition)) then
      begin
        AdhocPosition(Last.Coordinate);
      end;
    end;

    method LocationEnabled:tuple of (Boolean,String);
    begin
      if CLLocationManager.locationServicesEnabled then
      begin
        var status := locationManager.authorizationStatus;
        case status of
          CLAuthorizationStatus.AuthorizedAlways,
          CLAuthorizationStatus.AuthorizedWhenInUse:
          begin
            exit (true, 'Access');
          end;
          CLAuthorizationStatus.Denied,
          CLAuthorizationStatus.Restricted:
          begin
            exit (false, 'No Access');
          end;
        end;
      end
      else
      begin
        exit (false,'Turn On Location Services to Allow App to Determine Your Location');
      end;
    end;




  end;

end.