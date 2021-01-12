namespace Moshine.Services.Location.Models;

uses
  Foundation;

type

  Location = public class
  public
    property Id:String;

    property Description:String;
    property Latitude:Double;
    property Longitude:Double;

    property arrivalDate: NSDate;
    property departureDate: NSDate;

  end;

end.