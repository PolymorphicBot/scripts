import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginInstance()
Plugin plugin;

@BotInstance()
BotConnector bot;

final RegExp REGEX = new RegExp(r"((?:https|http)?:\/\/soundcloud\.com\/\S*)");

@OnMessage()
handleMessage(MessageEvent event) async {
  if (!REGEX.hasMatch(event.message)) {
    return;
  }

  var matches = REGEX.allMatches(event.message);

  for (var match in matches) {
    try {
      var url = match.group(1);
      var rurl = "http://api.soundcloud.com/resolve.json?url=${Uri.encodeComponent(url)}&client_id=YOUR_CLIENT_ID";
      var json = await fetchJSON(rurl);
      event.reply("${json.title}", prefix: true, prefixContent: "SoundCloud");
    } catch (e) {}
  }
}

@NotifyPlugin("link_title", methods: const ["blacklistExpression"])
blacklistLinkTitle(linkTitle) {
  linkTitle.blacklistExpression(r"((?:https|http)?:\/\/soundcloud\.com\/\S*)");
}
