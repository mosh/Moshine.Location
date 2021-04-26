namespace Moshine.Services.Location.Models;

uses
  CoreLocation, RemObjects.Elements.RTL;

type
  LastLocation = public class
    property Coordinate:CLLocationCoordinate2D := kCLLocationCoordinate2DInvalid;
    property When:DateTime := DateTime.UtcNow;
  end;

end.