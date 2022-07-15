namespace Moshine.Services.Location;

uses
  CoreLocation,
  Moshine.Services.Location.Models, RemObjects.Elements.RTL;

type
  [Cocoa]
  NotifyingLocationService = public class

  public
      class LocationNotification := 'NotifyingLocationService.LocationNotification';

  private
    property LocationService:LocationService;

    method receivedLocation(newLocation:Location);
    begin
      Log($'receivedLocation');
      LocationReceived := newLocation;
    end;

    method receivedPosition(value:CLLocationCoordinate2D);
    begin
      Log($'receivedPosition');
      PositionReceived := value;
      NSNotificationCenter.defaultCenter.postNotificationName(LocationNotification) object(nil);
      Log($'postNotification');
    end;

  public

    property LocationReceived:Location;
    property PositionReceived:CLLocationCoordinate2D;

    constructor;
    begin
      LocationService := new LocationService;
      LocationService.ReceivedLocation := @receivedLocation;
      LocationService.AdhocPosition := @receivedPosition;
      Log($'constructor');
    end;

    class method AddObserver(observer:id; aSelector:SEL);
    begin
      //selector(eventHandler:)
      NSNotificationCenter.defaultCenter.addObserver(observer) &selector(aSelector) name(LocationNotification) object(nil);

    end;

    method requestLocation;
    begin
      LocationService.requestLocation;
    end;
  end;

end.