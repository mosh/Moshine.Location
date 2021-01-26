namespace Moshine.Api.Location.Models.GPX;

uses
  RemObjects.Elements.RTL;

type

  GPXTrack = public class
  private
  protected
  public
    property Name:String;
    property Points:List<GPXPoint> := new List<GPXPoint>;
  end;

end.