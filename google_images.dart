import "dart:async";

import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;

@Command("image", description: "Fetches a Random Image from Google Images using the specified query", usage: "<query>")
image(CommandEvent event, [String type]) async {
  if (event.hasNoArguments) {
    event.usage();
    return;
  }

  var query = event.joinArgs();

  var url = await getGoogleImage(query, event, type: type);
  if (url == null) {
    event.reply("> Unable to find image for query.");
    return;
  }

  event << "[${Color.BLUE}Google Images${Color.RESET}] ${url}";
}

@Command("animate", description: "Fetches a Random Animated Image from Google Images using the specified query", usage: "<query>")
animate(CommandEvent event) async => await image(event, "animated");

@Command("face", description: "Fetches a Random Face Image from Google Images using the specified query", usage: "<query>")
face(CommandEvent event) async => await image(event, "face");

Future<String> getGoogleImage(String query, CommandEvent event, {String type}) {
  var q = {
    "v": "1.0",
    "rsz": "8",
    "q": query,
    "safe": "active"
  };
  
  if (type != null) {
    q["imgtype"] = type;
  }
  
  return fetchJSON("http://ajax.googleapis.com/ajax/services/search/images", query: q).then((response) {
    List<dynamic> images = response["responseData"] == null ? [] : response["responseData"]["results"];
    
    if (images.isEmpty) {
      return null;
    } else {
      var img = event.chooseAtRandom(images);
      return img["unescapedUrl"];
    }
  });
}