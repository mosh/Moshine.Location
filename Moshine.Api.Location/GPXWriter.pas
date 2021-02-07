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
      var linkElement := new XmlElement withName('link');
      linkElement.AddAttribute(new XmlAttribute('href',nil,someTrack.Link));
      var textElement := new XmlElement withName('text');
      textElement.Value := someTrack.LinkText;
      linkElement.AddElement(textElement);
      metaElement.AddElement(linkElement);
      var timeElement := new XmlElement withName('time');
      timeElement.Value := someTrack.Time.ToISO8601String;
      metaElement.AddElement(timeElement);

      var trkElement := new XmlElement withName('trk');

      gpxElement.AddElement(metaElement);
      gpxElement.AddElement(trkElement);
      var nameElement := new XmlElement withName('name');
      nameElement.Value :=  someTrack.Name;
      trkElement.AddElement(nameElement);

      var trksegElement := new XmlElement withName('trkseg');

      for each point in someTrack.Points do
      begin
        var trkptElement := new XmlElement withName('trkpt');
        var lonAttr := new XmlAttribute('lon',nil, Convert.ToString(Double(point.Coordinate.longitude)));
        trkptElement.AddAttribute(lonAttr);
        var latAttr := new XmlAttribute('lat',nil, Convert.ToString(Double(point.Coordinate.latitude)));
        trkptElement.AddAttribute(latAttr);

        var eleElement := new XmlElement withName('ele');
        eleElement.Value := Convert.ToString(point.Elevation);
        trkptElement.AddElement(eleElement);
        var trkptTimeElement := new XmlElement withName('time');
        trkptTimeElement.Value := point.Time.ToISO8601String;
        trkptElement.AddElement(trkptTimeElement);

        trksegElement.AddElement(trkptElement);
      end;

      trkElement.AddElement(trksegElement);

      var document := XmlDocument.WithRootElement(gpxElement);

      var options := new XmlFormattingOptions;
      options.NewLineForElements := true;
      options.WriteNewLineAtEnd := true;
      options.WhitespaceStyle := XmlWhitespaceStyle.PreserveWhitespaceAroundText;

      exit document.ToString(options);
    end;

  end;

end.