namespace Moshine.Api.Location;

uses
  Moshine.Api.Location.Models.GPX,
  RemObjects.Elements.RTL;

type

  GPXWriter = public class
  private
  protected
  public
    method Write(someTrack:GPXTrack):String;
    begin

      var gpxElement := new XmlElement withName('gpx');
      var metaElement := new XmlElement withName('metadata');
      var trkElement := new XmlElement withName('trk');

      gpxElement.AddElement(metaElement);
      gpxElement.AddElement(trkElement);
      var nameElement := new XmlElement withName('name');
      var nameTextElement := new XmlText(nameElement);
      nameTextElement.Value := someTrack.Name;
      trkElement.AddElement(nameElement);

      var trksegElement := new XmlElement withName('trkseg');

      for each point in someTrack.Points do
      begin
        var trkptElement := new XmlElement withName('trkpt');
        var lonAttr := new XmlAttribute('lon',nil, Convert.ToString(point.Coordinate.longitude));
        trkptElement.AddAttribute(lonAttr);
        var latAttr := new XmlAttribute('lat',nil, Convert.ToString(point.Coordinate.latitude));
        trkptElement.AddAttribute(latAttr);

        var eleElement := new XmlElement withName('ele');
        var eleValue := new XmlText(eleElement);
        eleValue.Value := Convert.ToString(point.Elevation);
        trkptElement.AddElement(eleElement);
        var timeElement := new XmlElement withName('time');
        var textElement := new XmlText (timeElement);
        textElement.Value := point.Time.ToString;

        trksegElement.AddElement(trkptElement);
      end;

      var document := XmlDocument.WithRootElement(gpxElement);

      exit document.ToString;
    end;

  end;

end.