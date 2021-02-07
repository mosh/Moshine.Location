namespace Moshine.Services.Location.Models;

{$IFDEF IOS}

uses
  Realm,
  RemObjects.Elements.RTL;

type

  Track = public class(RLMObject)
  private
  public
    property Id:String;
    property StartDate:DateTime;
    property Active:Boolean;

    class method primaryKey: NSString; override;
    begin
      exit 'Id';
    end;

  end;

{$ENDIF}

end.