namespace Moshine.Api.Location.Models.GPX;

uses
  Moshine.Api.Location.Models,
  RemObjects.Elements.RTL;
type
  Point = public class
  public
    property Coordinate:LocationCoordinate2D;
    property Elevation:Double;
    property Time: DateTime;

  end;

end.