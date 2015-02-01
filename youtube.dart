import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

import "dart:convert";

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;

var googleAPIKey = "AIzaSyBNTRakVvRuGHn6AVIhPXE_B3foJDOxmBU";
var LINK_REGEX = new RegExp(r'\(?\b((http|https)://|www[.])[-A-Za-z0-9+&@#/%?=~_()|!:,.;]*[-A-Za-z0-9+&@#/%=~_()|]');
var YT_INFO_LINK = 'https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics,contentDetails&key=${googleAPIKey}&id=';
var YT_LINK_ID = new RegExp(r'^.*(youtu.be/|v/|embed/|watch\?|youtube.com/user/[^#]*#([^/]*?/)*)\??v?=?([^#\&\?]*).*');
var DURATION_PARSER = new RegExp(r'^([0-9]+(?:[,\.][0-9]+)?H)?([0-9]+(?:[,\.][0-9]+)?M)?([0-9]+(?:[,\.][0-9]+)?S)?$');

@OnMessage()
void handleYouTube(MessageEvent event) {
  if (LINK_REGEX.hasMatch(event.message)) {
    LINK_REGEX.allMatches(event.message).forEach((match) {
      var url = match.group(0);
      if (url.contains("youtube") || url.contains("youtu.be")) {
        outputYouTubeInfo(event, url);
      }
    });
  }
}

String extractYouTubeID(String url) {
  var first = YT_LINK_ID.firstMatch(url);

  if (first == null) {
    return null;
  }
  return first.group(3);
}

void outputYouTubeInfo(MessageEvent event, String url) {
  var id = extractYouTubeID(url);
  
  if (id == null) {
    return;
  }
  
  var request_url = "${YT_INFO_LINK}${id}";
  
  plugin.httpClient.get(request_url).then((response) {
    var data = JSON.decode(response.body);
    var items = data['items'];
    var video = items[0];
    printYouTubeInfo(event, video);
  });
}

void printYouTubeInfo(MessageEvent event, info) {  
  var snippet = info["snippet"];
  var timeInput = info['contentDetails']['duration'].substring(2);
  var match = DURATION_PARSER.firstMatch(timeInput);
  var hours = match.group(1) != null ? int.parse(match.group(1).replaceAll('H', '')) : 0;
  var minutes = match.group(2) != null ? int.parse(match.group(2).replaceAll('M', '')) : 0;
  var seconds = match.group(3) != null ? int.parse(match.group(3).replaceAll('S', '')) : 0;
  var duration = new Duration(hours: hours, minutes: minutes, seconds: seconds).toString();
  duration = duration.substring(0, duration.length - 7);
  
  event.reply("${snippet['title']} | ${snippet['channelTitle']} (${Color.GREEN}${info['statistics']['likeCount']}${Color.RESET}:${Color.RED}${info['statistics']['dislikeCount']}${Color.RESET}) (${duration})", prefixContent: "YouTube");
}