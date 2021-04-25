namespace Moshine.Services.Location.ViewModels;

uses
  RemObjects.Elements.RTL;

type

  TrackViewModel = public class
  public
    property Id:String;
    property Start:DateTime;
    property Stopped:DateTime;
    property Distance:Double;
    property Locations:Integer;
  end;

end.