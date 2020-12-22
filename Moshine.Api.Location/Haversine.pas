namespace Moshine.Api.Location;

uses
  Moshine.Api.Location.Models;

type

  //
  // Reference
  // https://en.wikipedia.org/wiki/Great-circle_distance
  // https://en.wikipedia.org/wiki/Haversine_formula
  // http://rosettacode.org/wiki/Haversine_formula#C.23
  //

  Haversine = public class
  private

    class method ToRadians(angle:Double):Double;
    begin
    {$IF TOFFEE}
    exit (RemObjects.Elements.RTL.Consts.PI * angle) / 180.0;
    {$ELSE}
    // Net Core
    exit (system.Math.PI * angle) / 180.0;
    {$ENDIF}

    end;

  public
    class method Calculate(lat1:Double; lon1:Double; lat2:Double; lon2:Double):Double;
    begin
      var r := 6372.8; // In kilometres

      var dLat := ToRadians(lat2 - lat1);
      var dLon := ToRadians(lon2 - lon1);
      lat1 := ToRadians(lat1);
      lat2 := ToRadians(lat2);

      var a := RemObjects.Elements.RTL.Math.Sin(dLat / 2)
        * RemObjects.Elements.RTL.Math.Sin(dLat / 2)
        + RemObjects.Elements.RTL.Math.Sin(dLon / 2)
        * RemObjects.Elements.RTL.Math.Sin(dLon / 2)
        * RemObjects.Elements.RTL.Math.Cos(lat1)
        * RemObjects.Elements.RTL.Math.Cos(lat2);
      var c := 2 * RemObjects.Elements.RTL.Math.Asin(RemObjects.Elements.RTL.Math.Sqrt(a));
      exit r * 2 * RemObjects.Elements.RTL.Math.Asin(RemObjects.Elements.RTL.Math.Sqrt(a));

    end;
  end;

end.