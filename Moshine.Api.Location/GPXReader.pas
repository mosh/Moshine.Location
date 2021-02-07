namespace Moshine.Api.Location;

uses
  Moshine.Api.Location.Models,
  Moshine.Api.Location.Models.GPX,
  RemObjects.Elements.RTL;

type

  GPXReader = public class
  private
  protected

    method ProcessElements(someTrack:GPXTrack; elements: sequence of XmlElement);
    begin
      for each element in elements do
      begin
        case element.LocalName of
          'link':
            begin
              var hRef := element.Attributes.FirstOrDefault(a -> a.LocalName = 'href');
              if(assigned(hRef))then
              begin
                someTrack.Link := hRef.Value;
                someTrack.LinkText := element.Value;
              end;

            end;
          'name':
            begin
              someTrack.Name := element.Value;
            end;
          'trk':
            begin
            end;
          'trkpt':
            begin
              var newPoint := new GPXPoint;

              var lat := Convert.ToDouble(element.Attributes.First(a -> a.LocalName = 'lat').Value) as LineOfLatitude;
              var lon := Convert.ToDouble(element.Attributes.First(a -> a.LocalName = 'lon').Value) as LineOfLongitude;

              newPoint.Coordinate := new Moshine.Api.Location.Models.LocationCoordinate2D(lat, lon);

              someTrack.Points.Add(newPoint);


            end;
          'ele':
            begin
              var currentPoint := someTrack.Points[someTrack.Points.Count-1];
              currentPoint.Elevation := Convert.ToDouble(element.Value);
            end;
          'time':
            begin

              var time := DateTime.TryParseISO8601(element.Value);

              if(someTrack.Points.Count>0) then
              begin
                var currentPoint := someTrack.Points[someTrack.Points.Count-1];
                currentPoint.Time := time;
              end
              else
              begin
                someTrack.Time := time;
              end;
            end;
        end;
        ProcessElements(someTrack, element.Elements);
      end;

    end;

    method ProcessNodes(someTrack:GPXTrack; nodes:ImmutableList<XmlNode>);
    begin
      for each node in nodes do
      begin

        case node.NodeType of
          XmlNodeType.Element:
            begin
              var element:XmlElement := node as XmlElement;
              ProcessElements(someTrack, element.Elements);
              break;
            end;
        end;

      end;

    end;

  public

    method Read(text:String):GPXTrack;
    begin

      var newTrack := new GPXTrack;

      var parser := new XmlParser(text);

      var document := parser.Parse;

      ProcessNodes(newTrack, document.Nodes);

      exit newTrack;
    end;

  end;

end.