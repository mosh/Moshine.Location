namespace Moshine.Services.Location;

uses
  Moshine.Api.Location.Models,
  Moshine.Services.Location.Interfaces,
  Moshine.Services.Location.Models,
  Moshine.Services.Location.ViewModels,
  Realm,
  RemObjects.Elements.RTL;

type

  LocationStorage = public class(IStorage)
  private
    {$IFDEF MACOS}
    property RealmUrl:NSURL;
    property RealmForUrl:RLMRealm;
    {$ENDIF}


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

  public

    {$IFDEF MACOS}
    constructor withUrl(url:NSURL);
    begin
      RealmUrl := url;
    end;
    {$ELSE}
    constructor;
    begin
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

      if(assigned(ActiveTrack))then
      begin
        ActiveTrack.Active := false;
        Realm.addOrUpdateObject(activeTrack);

        id := activeTrack.Id;
      end;

      Realm.commitWriteTransaction;
      exit id;
      {$ELSE}
      raise new NotImplementedException;
      {$ENDIF}
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

    method trackStats:tuple of (Boolean, Integer);
    begin
      {$IFDEF TOFFEE}
      var count := Track.allObjectsInRealm(Realm).count;
      exit (assigned(ActiveTrack), count);
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

    method removeAllLocal;
    begin
      {$IFDEF TOFFEE}
      Realm.beginWriteTransaction;
      Realm.deleteObjects(Position.allObjectsInRealm(Realm));
      Realm.deleteObjects(Track.allObjectsInRealm(Realm));
      Realm.commitWriteTransaction;
      {$ELSE}
      raise new NotImplementedException;
      {$ENDIF}
    end;

    method tracks:sequence of TrackViewModel;
    begin
      {$IFDEF TOFFEE}
      var sortedTracks := Track.allObjectsInRealm(Realm).OrderByDescending(t -> t.startDate)
        .Select(t -> new TrackViewModel(Id := t.Id, Start := t.startDate)).ToList;
      exit sortedTracks;
      {$ELSE}
      exit nil;
      {$ENDIF}

    end;

  end;

end.