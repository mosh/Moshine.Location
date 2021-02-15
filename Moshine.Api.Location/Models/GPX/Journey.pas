namespace Moshine.Api.Location.Models.GPX;

uses
  RemObjects.Elements.RTL;

type
  GPXJourney = public class
  private
  protected
  public
    property Points:List<GPXPoint> := new List<GPXPoint>;
  end;

end.