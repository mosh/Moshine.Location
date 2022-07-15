namespace Moshine.Services.Location;

uses
  Moshine.Api.Location.Models,
  Moshine.Services.Location.Interfaces,
  Moshine.Services.Location.Models,
  Moshine.Services.Location.ViewModels,
{$IFNDEF WATCHOS}
  Realm,
{$ENDIF}
  RemObjects.Elements.RTL;

type

  LocationStorage = public class({$IFNDEF WATCHOS}IStorage{$ENDIF})
  private
{$IFDEF MACOS}
    property RealmUrl:NSURL;
    property RealmForUrl:RLMRealm;
{$ENDIF}

{$IFNDEF WATCHOS}
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
{$ENDIF}

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

{$IFNDEF WATCHOS}
    method startTrack:String;
    begin
      Realm.beginWriteTransaction;

      var track := ActiveTrack;

      if(assigned(track))then
      begin
        track.Active := false;
        Realm.addOrUpdateObject(track);

      end;

      var newTrack := new Track;
      newTrack.Id := Guid.NewGuid.ToString;
      newTrack.StartDate := DateTime.UtcNow;
      newTrack.Active := true;
      Realm.addOrUpdateObject(newTrack);
      Realm.commitWriteTransaction;
      exit newTrack.Id;
    end;
  {$ENDIF}

{$IFNDEF WATCHOS}
    method stopTrack:String;
    begin
      var id := '';

      Realm.beginWriteTransaction;

      var track := ActiveTrack;

      if(assigned(track))then
      begin
        track.Active := false;
        Realm.addOrUpdateObject(track);

        id := track.Id;
      end;

      Realm.commitWriteTransaction;
      exit id;
    end;
  {$ENDIF}

{$IFNDEF WATCHOS}
    property ActiveTrack:Track
      read
        begin
          var conditionBlock := method(item:Track):Boolean begin exit item.Active; end;
          exit Track.allObjectsInRealm(Realm).Cast<Track>.FirstOrDefault(t -> conditionBlock(t));
        end;

    method trackStats:tuple of (Boolean, Integer);
    begin
      var count := Track.allObjectsInRealm(Realm).count;
      var track := ActiveTrack;
      exit (assigned(track), count);
    end;

    method addPosition(latitude:Double; longitude:Double):Boolean;
    begin
      var added := false;

      Realm.beginWriteTransaction;

      var track := ActiveTrack;

      if(assigned(track))then
      begin

        var newPosition := new Position;
        newPosition.TrackId := track.Id;
        newPosition.Id := Guid.NewGuid.ToString;
        newPosition.Latitude := latitude;
        newPosition.Longitude := longitude;
        newPosition.Now := DateTime.UtcNow;
        Realm.addOrUpdateObject(newPosition);
        added := true;
      end;

      Realm.commitWriteTransaction;

      exit added;
    end;


    method positions(trackId:String):sequence of PositionViewModel;
    begin
      exit Position.allObjectsInRealm(Realm)
        .Cast<Position>
        .Where(p -> p.TrackId = trackId)
        .OrderBy(p -> p.Now)
        .Select(p -> new PositionViewModel(
          Now := p.Now,
          Location := new LocationCoordinate2D(Double(p.Latitude), Double(p.Longitude))
          )
          ).ToList;
    end;

    method removeAllLocal;
    begin
      Realm.beginWriteTransaction;
      Realm.deleteObjects(Position.allObjectsInRealm(Realm));
      Realm.deleteObjects(Track.allObjectsInRealm(Realm));
      Realm.commitWriteTransaction;
    end;

    method tracks:sequence of TrackViewModel;
    begin
      var allTracks := Track.allObjectsInRealm(Realm);
      var sortedTracks := allTracks
        .Cast<Track>
        .OrderByDescending(t -> t.StartDate)
        .Select(t -> new TrackViewModel(Id := t.Id, Start := t.StartDate)).ToList;
      exit sortedTracks;
    end;
{$ENDIF}

  end;

end.