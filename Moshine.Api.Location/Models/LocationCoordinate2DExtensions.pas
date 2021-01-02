namespace Moshine.Api.Location.Models;

uses
  RemObjects.Elements.RTL;

type

  BoundingBox = public class
  public
    property MinPoint: LocationCoordinate2D;
    property MaxPoint: LocationCoordinate2D;
  end;

  // http://janmatuschek.de/LatitudeLongitudeBoundingCoordinates


  LocationCoordinate2DExtensions = public extension class(LocationCoordinate2D)
  private
    // Semi-axes of WGS-84 geoidal reference
    const WGS84_a:Double = 6378137.0; // Major semiaxis [m]
    const WGS84_b:Double = 6356752.3; // Minor semiaxis [m]


    // degrees to radians
    class method Degrees2Radians(degrees:Double):Double;
    begin
      {$IFDEF ECHOES}
      exit System.Math.PI * degrees / 180.0;
      {$ELSEIF TOFFEE}
      exit M_PI * degrees / 180.0;
      {$ELSE}
      raise new NotImplementedException;
      {$ENDIF}
    end;

    // radians to degrees
    class method Radians2Degrees(radians:Double):Double;
    begin
      {$IFDEF ECHOES}
      exit 180.0 * radians / System.Math.PI;
      {$ELSEIF TOFFEE}
      exit 180.0 * radians / M_PI;
      {$ELSE}
      raise new NotImplementedException;
      {$ENDIF}
    end;

    // Earth radius at a given latitude, according to the WGS-84 ellipsoid [m]
    class method WGS84EarthRadius(lat:Double):Double;
    begin
      // http://en.wikipedia.org/wiki/Earth_radius
      var An := WGS84_a * WGS84_a * Math.Cos(lat);
      var Bn := WGS84_b * WGS84_b * Math.Sin(lat);
      var Ad := WGS84_a * Math.Cos(lat);
      var Bd := WGS84_b * Math.Sin(lat);
      exit Math.Sqrt((An*An + Bn*Bn) / (Ad*Ad + Bd*Bd));
    end;

  public
    // https://stackoverflow.com/questions/238260/how-to-calculate-the-bounding-box-for-a-given-lat-lng-location
    // 'halfSideInKm' is the half length of the bounding box you want in kilometers.
    method  GetBoundingBox(halfSideInKm:Double):BoundingBox;
    begin
      // Bounding box surrounding the point at given coordinates,
      // assuming local approximation of Earth surface as a sphere
      // of radius given by WGS84
      var lat := Degrees2Radians(self.Latitude);
      var lon := Degrees2Radians(self.Longitude);
      var halfSide := 1000 * halfSideInKm;

      // Radius of Earth at given latitude
      var radius := WGS84EarthRadius(lat);
      // Radius of the parallel at given latitude
      var pradius := radius * Math.Cos(lat);

      var latMin := lat - halfSide / radius;
      var latMax := lat + halfSide / radius;
      var lonMin := lon - halfSide / pradius;
      var lonMax := lon + halfSide / pradius;

      exit new BoundingBox (
          MinPoint := new LocationCoordinate2D ( Latitude := Radians2Degrees(latMin), Longitude := Radians2Degrees(lonMin) ),
          MaxPoint := new LocationCoordinate2D ( Latitude := Radians2Degrees(latMax), Longitude := Radians2Degrees(lonMax) )
          );
    end;

    // http://mathforum.org/library/drmath/view/55417.html
    method BearingToLocation(destination:LocationCoordinate2D):Double;
    begin
      var atan2Left := Math.Sin(destination.Longitude-self.Longitude)*Math.Cos(destination.Latitude);
      var atan2Right := Math.Cos(self.Latitude)*Math.Sin(destination.Latitude)-Math.Sin(self.Latitude)*Math.Cos(destination.Latitude)*Math.Cos(destination.Longitude-self.Longitude);
      exit Math.Atan2(atan2Left, atan2Right) mod 2*RemObjects.Elements.RTL.Consts.PI;
    end;


    //
    // Reference
    // https://en.wikipedia.org/wiki/Great-circle_distance
    // https://en.wikipedia.org/wiki/Haversine_formula
    // http://rosettacode.org/wiki/Haversine_formula#C.23
    //

    method GreatCircleDistance(destination:LocationCoordinate2D):Double;
    begin
      var r := 6372.8; // In kilometres

      var dLat := Degrees2Radians(destination.Latitude - self.Latitude);
      var dLon := Degrees2Radians(destination.Longitude - self.Longitude);
      var lat1 := Degrees2Radians(self.Latitude);
      var lat2 := Degrees2Radians(destination.Latitude);

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