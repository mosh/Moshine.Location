namespace Moshine.Api.Location;

type
  LocationConvert = public static class
  private
  protected
  public
    method KilometresToNauticalMiles(distance:Double):Double;
    begin
      exit distance / 1.852;
    end;
  end;

end.