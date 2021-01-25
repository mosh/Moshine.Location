namespace Moshine.Api.Location.Models.GPX;

uses
  RemObjects.Elements.RTL;

type

  Track = public class
  private
  protected
  public
    property Name:String;
    property Points:List<Point> := new List<Point>;
  end;

end.