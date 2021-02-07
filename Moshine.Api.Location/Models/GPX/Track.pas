namespace Moshine.Api.Location.Models.GPX;

uses
  RemObjects.Elements.RTL;

type

  GPXTrack = public class
  private
  protected
  public
    property Link:String;
    property LinkText:String;
    property Name:String;
    property Points:List<GPXPoint> := new List<GPXPoint>;
    property Time:DateTime;
  end;

end.