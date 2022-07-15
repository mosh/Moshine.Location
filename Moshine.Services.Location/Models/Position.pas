namespace Moshine.Services.Location.Models;

{$IFNDEF WATCHOS}

uses
  Realm,
  RemObjects.Elements.RTL;

type

  Position = public class(RLMObject)
  private
  protected
  public
    property TrackId:String;
    property Id:String;
    property Latitude:Double;
    property Longitude:Double;
    property Now:DateTime;

    class method primaryKey: NSString; override;
    begin
      exit 'Id';
    end;

  end;

{$ENDIF}


end.