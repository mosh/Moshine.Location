namespace Moshine.Api.Location;

uses
  Moshine.Api.Location.Models,
  Moshine.Api.Location.Models.GPX,
  RemObjects.Elements.RTL;

type

  GPXReader = public class
  private
  protected

    method ProcessElements(newGPX:GPX; elements: sequence of XmlElement; createdPoint:GPXPoint);
    begin

      var currentPoint:GPXPoint := nil;

      if(assigned(createdPoint))then
      begin
        currentPoint := createdPoint;
      end;

      for each element in elements do
      begin
        case element.LocalName of
          'link':
            begin
              var hRef := element.Attributes.FirstOrDefault(a -> a.LocalName = 'href');
              if(assigned(hRef))then
              begin
                newGPX.Link := hRef.Value;
                newGPX.LinkText := element.Value;
              end;

            end;
          'name':
            begin
              newGPX.Track.Name := element.Value;
            end;
          'trk':
            begin
            end;
          'wpt','trkpt':
            begin
              var newPoint := new GPXPoint;

              var lat := Convert.ToDouble(element.Attributes.First(a -> a.LocalName = 'lat').Value);
              var lon := Convert.ToDouble(element.Attributes.First(a -> a.LocalName = 'lon').Value);

              newPoint.Coordinate := new Moshine.Api.Location.Models.LocationCoordinate2D(lat, lon);

              case element.LocalName of
                'wpt':
                  newGPX.Journey.Points.Add(newPoint);
                'trkpt':
                  newGPX.Track.Points.Add(newPoint);
              end;

              currentPoint := newPoint;


            end;
          'ele':
            begin
              if(assigned(currentPoint))then
              begin
                currentPoint.Elevation := Convert.ToDouble(element.Value);
              end;
            end;
          'time':
            begin

              var time := DateTime.TryParseISO8601(element.Value);

              if(assigned(currentPoint)) then
              begin
                currentPoint.Time := time;
              end
              else
              begin
                newGPX.Time := time;
              end;
            end;
        end;
        ProcessElements(newGPX, element.Elements, currentPoint);
      end;

    end;

    method ProcessNodes(newGPX:GPX; nodes:ImmutableList<XmlNode>);
    begin
      for each node in nodes do
      begin

        case node.NodeType of
          XmlNodeType.Element:
            begin
              var element:XmlElement := node as XmlElement;
              ProcessElements(newGPX, element.Elements,nil);
              break;
            end;
        end;

      end;

    end;

  public

    method Read(text:String):GPX;
    begin

      var newGPX := new GPX;

      var parser := new XmlParser(text);

      var document := parser.Parse;

      ProcessNodes(newGPX, document.Nodes);

      exit newGPX;
    end;

  end;

end.