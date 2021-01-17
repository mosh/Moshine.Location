namespace Moshine.Api.Location.Models;

type

  LineOfLatitude = public type Double;
  LineOfLongitude = public type Double;

  {$IF TOFFEE}
  PlatformLocationCoordinate2D = public CoreLocation.CLLocationCoordinate2D;
  {$ELSE}
  PlatformLocationCoordinate2D = public class
  public
    property latitude:LineOfLatitude read write;
    property longitude:LineOfLongitude read write;

  end;
  {$ENDIF}

  LocationCoordinate2D = public class mapped to PlatformLocationCoordinate2D

  public
    property latitude: LineOfLatitude
      read mapped.latitude as LineOfLatitude
      write
      begin
        {$IF TOFFEE}
        mapped.latitude := Double(value);
        {$ELSE}
        mapped.latitude := value;
        {$ENDIF}

      end;

    property longitude: LineOfLongitude
      read mapped.longitude as LineOfLongitude
      write
      begin
        {$IF TOFFEE}
        mapped.longitude := Double(value);
        {$ELSE}
        mapped.longitude := value;
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

    constructor(latitudeValue:LineOfLatitude;longitudeValue:LineOfLongitude);
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