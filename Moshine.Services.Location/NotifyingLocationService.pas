namespace Moshine.Services.Location;

uses
  CoreLocation,
  Moshine.Services.Location.Models;

type
  [Cocoa]
  NotifyingLocationService = public class

  public
      LocationNotification := 'NotifyingLocationService.LocationNotification';
  private
    property LocationService:LocationService;

    method receivedLocation(newLocation:Location);
    begin
    end;

    method receivedPosition(value:CLLocationCoordinate2D);
    begin

      NSNotificationCenter.defaultCenter.postNotificationName(LocationNotification) object(nil);
    end;

  public
    constructor;
    begin
      LocationService := new LocationService;
      LocationService.ReceivedLocation := @receivedLocation;
      LocationService.AdhocPosition := @receivedPosition;
    end;
  end;

end.