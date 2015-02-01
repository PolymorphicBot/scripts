import "dart:async";
import "dart:convert";

import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

const String KEY = "50b6a4b7956e5934de00d0e43c10b78e7a67da3eef3e50662";

@PluginInstance()
Plugin plugin;

@BotInstance()
BotConnector bot;

@Command("wordnik", description: "Define a Word using Wordnik", usage: "<word>")
wordnik(CommandEvent event) {
  if (event.argc == 0) {
    event.usage();
  } else {
    define(event.args.join(" ")).then((def) {
      if (def == null) {
        event.reply("[${Color.BLUE}Wordnik${Color.RESET}] Word Not Found");
        return;
      }
      
      event.reply("[${Color.BLUE}Wordnik${Color.RESET}] ${def.word}: ${def.definition}");
    });
  }
}

Future<Definition> define(String word) {
  return plugin.httpClient.get("http://api.wordnik.com/v4/word.json/${Uri.encodeComponent(word)}/definitions?limit=1&includeRelated=true&useCanonical=true&includeTags=false&api_key=${KEY}").then((response) {
    List<Map<String, dynamic>> data = JSON.decode(response.body);
    
    if (data.length == 0) {
      return new Future.value(null);
    } else {
      var first = data.first;
      return new Future.value(new Definition(first["word"], first["text"]));
    }
  });
}

class Definition {
  final String word;
  final String definition;
  
  Definition(this.word, this.definition);
}