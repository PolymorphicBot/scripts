import "dart:async";
import "dart:convert";

import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginInstance()
Plugin plugin;

@BotInstance()
BotConnector bot;

@Command("urban", description: "Define a Word using Urban Dictionary", usage: "<word>")
urban(CommandEvent event) {
  if (event.argc == 0) {
    event.usage();
  } else {
    define(event.args.join(" ")).then((def) {
      if (def == null) {
        event.reply("[${Color.BLUE}Urban${Color.RESET}] Word Not Found");
        return;
      }
      
      event.reply("[${Color.BLUE}Urban${Color.RESET}] ${def.word}: ${def.definition}");
    });
  }
}

Future<Definition> define(String word) {
  return plugin.httpClient.get("http://api.urbandictionary.com/v0/define?term=${Uri.encodeComponent(word)}").then((response) {
    var body = JSON.decode(response.body);
    var data = body["list"];
    
    if (data.length == 0) {
      return new Future.value(null);
    } else {
      var first = data.first;
      return new Future.value(new Definition(first["word"], first["definition"]));
    }
  });
}

class Definition {
  final String word;
  final String definition;
  
  Definition(this.word, this.definition);
}