import "dart:async";
import 'package:html5lib/parser.dart' as html5 show parse;

import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

const dependencies = const {
  "html5lib": "any"
};

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;

final RegExp LINK_REGEX = new RegExp(r'\(?\b((http|https)://|www[.])[-A-Za-z0-9+&@#/%?=~_()|!:,.;]*[-A-Za-z0-9+&@#/%=~_()|]');
final RegExp NO_SPECIAL_CHARS = new RegExp(r'''[^\w`~!@#$%^&*()\-_=+\[\]:'",<.>/?\\| ]''');
final RegExp NO_MULTI_SPACES = new RegExp(r' {2,}');
final RegExp YT_LINK = new RegExp(r'^.*(youtu.be/|v/|embed/|watch\?|youtube.com/user/[^#]*#([^/]*?/)*)\??v?=?([^#\&\?]*).*');

@OnMessage()
void handleMessage(MessageEvent event) {
  var msg = event.message;
  if (LINK_REGEX.hasMatch(msg)) {
    for (var match in LINK_REGEX.allMatches(msg)) {

      var url = match.group(0);

      if (url.contains("github.com/")) {
        return;
      }

      if (YT_LINK.hasMatch(url)) return;
      
      getLinkTitle(url).then((title) {
        if (title == null || title.toString() == "null") {
          return;
        }
        
        event.reply(title, prefixContent: "Link Title");
      }).catchError((e) {});
    }
  }
}

@RemoteMethod()
Future<String> getLinkTitle(String url) {
  return plugin.httpClient.get(url).then((response) {
    if (response.statusCode != 200) {
      throw new Exception("FAIL");
    }

    try {
      var document = html5.parse(response.body);

      if (document == null) {
        throw new Exception("FAIL");
      }

      var title = document.querySelector('title').text;

      if (title == null || title.isEmpty) {
        throw new Exception("FAIL");
      }

      title = title.replaceAll(NO_SPECIAL_CHARS, ' ').replaceAll(NO_MULTI_SPACES, ' ').trim();
      return title;
    } catch (e) {}
  });
}