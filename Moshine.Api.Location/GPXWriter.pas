namespace Moshine.Api.Location;

uses
  Moshine.Api.Location.Models.GPX,
  RemObjects.Elements.RTL;

type

  GPXWriter = public class
  private
  protected
  public
    method Write(someGPX:GPX):String;
    begin

      var gpxElement := new XmlElement withName('gpx');

      if((assigned(someGPX.Time)) or (not String.IsNullOrEmpty(someGPX.Link)) or (not String.IsNullOrEmpty(someGPX.LinkText))) then
      begin

        var metaElement := new XmlElement withName('metadata');
        gpxElement.AddElement(metaElement);

        if((not String.IsNullOrEmpty(someGPX.Link)) or (not String.IsNullOrEmpty(someGPX.LinkText)))then
        begin
          var linkElement := new XmlElement withName('link');

          if(not String.IsNullOrEmpty(someGPX.Link))then
          begin
              linkElement.AddAttribute(new XmlAttribute('href',nil,someGPX.Link));
              if(not String.IsNullOrEmpty(someGPX.LinkText))then
              begin
                var textElement := new XmlElement withName('text');
                textElement.Value := someGPX.LinkText;
                linkElement.AddElement(textElement);
              end;

          end;
          metaElement.AddElement(linkElement);
        end;

        if(assigned(someGPX.Time))then
        begin
          var timeElement := new XmlElement withName('time');
          timeElement.Value := someGPX.Time.ToISO8601String;
          metaElement.AddElement(timeElement);
        end;
      end;

      if (someGPX.Track.Points.Any) then
      begin

        var trkElement := new XmlElement withName('trk');

        gpxElement.AddElement(trkElement);
        var nameElement := new XmlElement withName('name');
        nameElement.Value :=  someGPX.Track.Name;
        trkElement.AddElement(nameElement);

        var trksegElement := new XmlElement withName('trkseg');

        for each point in someGPX.Track.Points do
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
      end;

      if(someGPX.Journey.Points.Any)then
      begin
        for each point in someGPX.Journey.Points do
        begin
          var wptElement := new XmlElement withName('wpt');
          var lonAttr := new XmlAttribute('lon',nil, Convert.ToString(Double(point.Coordinate.longitude)));
          wptElement.AddAttribute(lonAttr);
          var latAttr := new XmlAttribute('lat',nil, Convert.ToString(Double(point.Coordinate.latitude)));
          wptElement.AddAttribute(latAttr);

          var eleElement := new XmlElement withName('ele');
          eleElement.Value := Convert.ToString(point.Elevation);
          wptElement.AddElement(eleElement);
          var wptTimeElement := new XmlElement withName('time');
          wptTimeElement.Value := point.Time.ToISO8601String;
          wptElement.AddElement(wptTimeElement);

          gpxElement.AddElement(wptElement);

        end;

      end;

      var document := XmlDocument.WithRootElement(gpxElement);

      var options := new XmlFormattingOptions;
      options.NewLineForElements := true;
      options.WriteNewLineAtEnd := true;
      options.WhitespaceStyle := XmlWhitespaceStyle.PreserveWhitespaceAroundText;

      exit document.ToString(options);
    end;

  end;

end.