namespace Moshine.Services.Location;

uses
  CoreLocation,
  Moshine.Services.Location.Models,
  Moshine.Services.Location.ViewModels,
  Moshine.Api.Location,
  Moshine.Api.Location.Models,
  Realm,
  RemObjects.Elements.RTL;

type

  TrackDelegate = public block (value:TrackViewModel);
  ReceivedLocationDelegate = public block(value:Location);

  [Cocoa]
  LocationService = public class(ICLLocationManagerDelegate)
  private

    {$IFDEF MACOS}
    property RealmUrl:NSURL;
    property RealmForUrl:RLMRealm;
    {$ENDIF}

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

    property Realm:RLMRealm
      read
        begin
          {$IFDEF MACOS}
          if(assigned(RealmForUrl))then
          begin
            exit RealmForUrl;
          end
          else
          begin
            RealmForUrl := RLMRealm.realmWithURL(RealmUrl);
            exit RealmForUrl;
          end;
          {$ELSE}
          exit RLMRealm.defaultRealm;
          {$ENDIF}
        end;

    method receivedVisit(visit:CLVisit) WithDescription(description:String);
    begin

      var newLocation := new Location;

      newLocation.Id := Guid.NewGuid.ToString;
      newLocation.arrivalDate := visit.arrivalDate;
      newLocation.departureDate := visit.departureDate;
      newLocation.Description := description;
      newLocation.Latitude := visit.coordinate.latitude;
      newLocation.Longitude := visit.coordinate.longitude;

      if (addPosition(newLocation.Latitude, newLocation.Longitude))then
      begin
        if(assigned(ReceivedLocation))then
        begin
          ReceivedLocation(newLocation);
        end;
      end;


    end;

    method locationManager(manager: CLLocationManager) didFailWithError(error: NSError);
    begin

    end;

    method locationManager(manager: CLLocationManager) didUpdateLocations(locations: NSArray<CLLocation>);
    begin

    end;

    property ActiveTrack:Track
      read
        begin
          {$IFDEF TOFFEE}
          var conditionBlock := method(item:Track):Boolean begin exit item.Active; end;
          exit Track.allObjectsInRealm(Realm).FirstOrDefault(t -> conditionBlock(t));
          {$ELSE}
          raise new NotImplementedException;
          {$ENDIF}
        end;


  public

    property ReceivedLocation:ReceivedLocationDelegate;

    constructor;
    begin

      workerQueue := new NSOperationQueue;

      locationManager.requestAlwaysAuthorization;
      locationManager.startMonitoringVisits;
      locationManager.delegate := self;

      locationManager.distanceFilter := 35; // 0
      locationManager.allowsBackgroundLocationUpdates := true; // 1
      locationManager.startUpdatingLocation;  // 2


    end;

    {$IFDEF MACOS}

    constructor withFile(url:NSURL);
    begin
      constructor;

      RealmUrl := url;
    end;

    {$ENDIF}

    method startTrack:String;
    begin
      {$IFDEF TOFFEE}
      var id := '';

      Realm.beginWriteTransaction;

      var activeTrack := ActiveTrack;

      if(assigned(activeTrack))then
      begin
        activeTrack.Active := false;
        Realm.addOrUpdateObject(activeTrack);

      end;

      var newTrack := new Track;
      newTrack.Id := Guid.NewGuid.ToString;
      newTrack.StartDate := DateTime.UtcNow;
      newTrack.Active := true;
      Realm.addOrUpdateObject(newTrack);
      Realm.commitWriteTransaction;
      exit newTrack.Id;
      {$ELSE}
      raise new NotImplementedException;
      {$ENDIF}
    end;

    method stopTrack:String;
    begin
      {$IFDEF TOFFEE}

      var id := '';

      Realm.beginWriteTransaction;

      var activeTrack := ActiveTrack;

      if(assigned(activeTrack))then
      begin
        activeTrack.Active := false;
        Realm.addOrUpdateObject(activeTrack);

        id := activeTrack.Id;
      end;

      Realm.commitWriteTransaction;
      exit id;
      {$ELSE}
      raise new NotImplementedException;
      {$ENDIF}
    end;

    method trackInformation(trackId:String): tuple of (Start:DateTime, Stopped:DateTime, Distance:Double);
    begin
      {$IFDEF TOFFEE}

      var allTrackLocations := Position.allObjectsInRealm(Realm).Where(l -> l.TrackId = trackId).OrderBy(l -> l.Now).ToList;

      if(allTrackLocations.Count >= 2)then
      begin
        var start := allTrackLocations.First.Now;
        var stopped := allTrackLocations[allTrackLocations.Count -1].Now;

        var distance:Double := 0;

        for x:Integer := 1 to allTrackLocations.Count -1 do
        begin
          var previous := allTrackLocations[x-1];
          var current := allTrackLocations[x];

          var difference := new LocationCoordinate2D(previous.Latitude, previous.Longitude).GreatCircleDistance(new LocationCoordinate2D(current.Latitude, current.Longitude));

          distance := distance + difference;

        end;

        exit (start, stopped, distance);


      end;

      exit (nil, nil, 0);
      {$ELSE}
      raise new NotImplementedException;
      {$ENDIF}

    end;

    method trackStats:tuple of (Boolean, Integer);
    begin
      {$IFDEF TOFFEE}
      var activeTrack := ActiveTrack;
      var count := Track.allObjectsInRealm(Realm).count;
      exit (assigned(activeTrack), count);
      {$ELSE}
      raise new NotImplementedException;
      {$ENDIF}
    end;

    method addPosition(latitude:Double; longitude:Double):Boolean;
    begin
      {$IFDEF TOFFEE}
      var added := false;

      Realm.beginWriteTransaction;

      var activeTrack := ActiveTrack;

      if(assigned(activeTrack))then
      begin

        var newPosition := new Position;
        newPosition.TrackId := activeTrack.Id;
        newPosition.Id := Guid.NewGuid.ToString;
        newPosition.Latitude := latitude;
        newPosition.Longitude := longitude;
        newPosition.Now := DateTime.UtcNow;
        Realm.addOrUpdateObject(newPosition);
        added := true;
      end;

      Realm.commitWriteTransaction;

      exit added;
      {$ELSE}
      raise new NotImplementedException;
      {$ENDIF}
    end;

    method positions(trackId:String):sequence of PositionViewModel;
    begin
      {$IFDEF TOFFEE}
      exit Position.allObjectsInRealm(Realm)
        .Where(p -> p.TrackId = trackId)
        .OrderBy(p -> p.Now)
        .Select(p -> new PositionViewModel( Now := p.Now, Location := new LocationCoordinate2D(p.Latitude, p.Longitude))).ToList;
      {$ELSE}
      raise new NotImplementedException;
      {$ENDIF}

    end;

    method tracks:sequence of TrackViewModel;
    begin
      {$IFDEF TOFFEE}
      var sortedTracks := Track.allObjectsInRealm(Realm).OrderByDescending(t -> t.StartDate)
        .Select(t -> new TrackViewModel(Id := t.Id, Start := t.StartDate)).ToList;
      exit sortedTracks;
      {$ELSE}
      exit nil;
      {$ENDIF}
    end;

    method tracks(updatesDelegate:TrackDelegate):sequence of TrackViewModel;
    begin
      {$IFDEF TOFFEE}

      var sortedTracks := Track.allObjectsInRealm(Realm).OrderByDescending(t -> t.StartDate)
        .Select(t -> new TrackViewModel(Id := t.Id, Start := t.StartDate)).ToList;

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
      {$ELSE}
      raise new NotImplementedException;
      {$ENDIF}

    end;


    method didVisitLocation(visit:CLVisit);
    begin
      locationManager(self.locationManager) didVisit(visit);
    end;

    method removeAllLocal;
    begin

      Realm.beginWriteTransaction;
      Realm.deleteObjects(Position.allObjectsInRealm(Realm));
      Realm.deleteObjects(Track.allObjectsInRealm(Realm));
      Realm.commitWriteTransaction;


    end;


  end;

end.