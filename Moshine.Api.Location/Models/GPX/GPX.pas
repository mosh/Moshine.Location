namespace Moshine.Api.Location.Models.GPX;

uses
  RemObjects.Elements.RTL;

type
  GPX = public class
  private
  protected
  public
    property Link:String;
    property LinkText:String;
    property Time:DateTime;

    property Track:GPXTrack := new GPXTrack;
    property Journey:GPXJourney := new GPXJourney;

  end;

end.