namespace Moshine.Api.Location.Models;

type

  LineOfLatitude = public type Double;
  LineOfLongitude = public type Double;


  {$IF TOFFEE OR DARWIN}
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
        {$IF TOFFEE OR DARWIN}
        mapped.latitude := Double(value);
        {$ELSE}
        mapped.latitude := value;
        {$ENDIF}

      end;

    property longitude: LineOfLongitude
      read mapped.longitude as LineOfLongitude
      write
      begin
        {$IF TOFFEE OR DARWIN}
        mapped.longitude := Double(value);
        {$ELSE}
        mapped.longitude := value;
        {$ENDIF}

      end;

    {$IF TOFFEE OR DARWIN}
    constructor;
    begin
      self := CoreLocation.CLLocationCoordinate2DMake(0, 0);
    end;
    {$ELSE}
    constructor; mapped to constructor;
    {$ENDIF}

    constructor(latitudeValue:Double;longitudeValue:Double);
    begin

      {$IF TOFFEE OR DARWIN}
      self := CoreLocation.CLLocationCoordinate2DMake(latitudeValue as Double, longitudeValue as Double);
      {$ELSE}
      mapped constructor;
      self.latitude := LineOfLatitude(latitudeValue);
      self.longitude := LineOfLongitude(longitudeValue);
      {$ENDIF}

    end;

  end;


end.