namespace Moshine.Services.Location.Interfaces;

uses
  Moshine.Services.Location.Models, Moshine.Services.Location.ViewModels, RemObjects.Elements.RTL;

type

  IStorage = public interface

    method startTrack:String;
    method stopTrack:String;
    method trackStats:tuple of (Boolean, Integer);
    method addPosition(latitude:Double; longitude:Double):Boolean;

    property ActiveTrack:Track read;

    method tracks:sequence of TrackViewModel;

    method positions(trackId:String):sequence of PositionViewModel;
    method positionsForTrack(trackId:String):List<Position>;

    method removeAllLocal;


  end;

end.