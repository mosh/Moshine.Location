namespace Moshine.Services.Location.ViewModels;

uses
  Moshine.Api.Location.Models,
  RemObjects.Elements.RTL;

type
  PositionViewModel = public class
  public
    property Location:LocationCoordinate2D;
    property Now:DateTime;
  end;

end.