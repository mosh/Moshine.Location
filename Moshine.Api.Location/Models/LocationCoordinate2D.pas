namespace Moshine.Api.Location.Models;

type

  Latitude = public type Double;
  Longitude = public type Double;

  {$IF TOFFEE}
  PlatformLocationCoordinate2D = public CoreLocation.CLLocationCoordinate2D;
  {$ELSE}
  PlatformLocationCoordinate2D = public class
  public
    property Latitude:Latitude read write;
    property Longitude:Longitude read write;

  end;
  {$ENDIF}

  LocationCoordinate2D = public class mapped to PlatformLocationCoordinate2D

  public
    property latitude: Latitude
      read mapped.latitude as Latitude
      write
      begin
        {$IF TOFFEE}
        mapped.latitude := Double(value);
        {$ELSE}
        mapped.Latitude := value;
        {$ENDIF}

      end;

    property longitude: Longitude
      read mapped.longitude as Longitude
      write
      begin
        {$IF TOFFEE}
        mapped.longitude := Double(value);
        {$ELSE}
        mapped.Longitude := value;
        {$ENDIF}

      end;

    {$IF TOFFEE}
    constructor;
    begin
      self := CoreLocation.CLLocationCoordinate2DMake(0, 0);
    end;
    {$ELSE}
    constructor; mapped to constructor;
    {$ENDIF}

    constructor(latitudeValue:Latitude;longitudeValue:Longitude);
    begin

      {$IF TOFFEE}
      self := CoreLocation.CLLocationCoordinate2DMake(latitudeValue as Double, longitudeValue as Double);
      {$ELSE}
      self := new LocationCoordinate2D;
      self.latitude := latitudeValue ;
      self.longitude := longitudeValue;
      {$ENDIF}

    end;


  end;


end.