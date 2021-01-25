namespace Moshine.Api.Location;

uses
  Moshine.Api.Location.Models,
  Moshine.Api.Location.Models.GPX,
  RemObjects.Elements.RTL;

type

  GPXReader = public class
  private
  protected

    method ProcessElements(someTrack:Track; elements: sequence of XmlElement);
    begin
      for each element in elements do
      begin
        writeLn(element.LocalName);
        case element.LocalName of
          'trk':
            begin
            end;
          'trkpt':
            begin
              var newPoint := new Point;

              var lat := Convert.ToDouble(element.Attributes.First(a -> a.LocalName = 'lat').Value) as LineOfLatitude;
              var lon := Convert.ToDouble(element.Attributes.First(a -> a.LocalName = 'lon').Value) as LineOfLongitude;

              newPoint.Coordinate := new Moshine.Api.Location.Models.LocationCoordinate2D(lat, lon);
              newPoint.Elevation := Convert.ToDouble(element.Attributes.First(a -> a.LocalName = 'ele').Value);

              someTrack.Points.Add(newPoint);
            end;
        end;
        ProcessElements(someTrack, element.Elements);
      end;

    end;

    method ProcessNodes(someTrack:Track; nodes:ImmutableList<XmlNode>);
    begin
      for each node in nodes do
      begin

        case node.NodeType of
          XmlNodeType.Element:
            begin
              var element:XmlElement := node as XmlElement;
              writeLn(element.LocalName);
              //ProcessNodes(someTrack, element.Nodes);
              ProcessElements(someTrack, element.Elements);
              break;
            end;
        end;

      end;

    end;

  public

    method Read(text:String):Track;
    begin

      var newTrack := new Track;

      var parser := new XmlParser(text);

      var document := parser.Parse;

      ProcessNodes(newTrack, document.Nodes);

      exit newTrack;
    end;

  end;

end.