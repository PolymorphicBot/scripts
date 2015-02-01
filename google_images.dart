import "dart:async";

import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

import "package:path/path.dart" show extension;

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;

@Command("image", description: "Fetches a Random Image from Google Images using the specified query", usage: "<query>")
image(CommandEvent event) {
  if (event.hasNoArguments) {
    event.usage();
    return;
  }
  
  var query = event.joinArgs();
  
  getGoogleImage(query, event).then((url) {
    if (url == null) {
      event.reply("> Unable to find image for query.");
      return;
    }
    
    event.reply(url, prefixContent: "Google Images");
  });
}

@Command("animate", description: "Fetches a Random Animated Image from Google Images using the specified query", usage: "<query>")
animate(CommandEvent event) {
  if (event.hasNoArguments) {
    event.usage();
    return;
  }
  
  var query = event.joinArgs();
  
  getGoogleImage(query, event, type: "animated").then((url) {
    if (url == null) {
      event.reply("> Unable to find image for query.");
      return;
    }
    
    event.reply(url, prefixContent: "Google Images");
  });
}

@Command("face", description: "Fetches a Random Face Image from Google Images using the specified query", usage: "<query>")
face(CommandEvent event) {
  if (event.hasNoArguments) {
    event.usage();
    return;
  }
  
  var query = event.joinArgs();
  
  getGoogleImage(query, event, type: "face").then((url) {
    if (url == null) {
      event.reply("> Unable to find image for query.");
      return;
    }
    
    event.reply(url, prefixContent: "Google Images");
  });
}

Future<String> getGoogleImage(String query, CommandEvent event, {String type}) {
  return event.fetchJSON("http://ajax.googleapis.com/ajax/services/search/images", query: {
    "v": "1.0",
    "rsz": "8",
    "q": query,
    "safe": "active"
  }..addAll(type != null ? { "type": type } : {})).then((response) {
    List<dynamic> images = response["responseData"] == null ? [] : response["responseData"]["results"];
    
    if (images.isEmpty) {
      return null;
    } else {
      var img = event.chooseAtRandom(images);
      return img["unescapedUrl"];
    }
  });
}