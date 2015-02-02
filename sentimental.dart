import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

import "dart:convert";

@PluginInstance()
Plugin plugin;

@BotInstance()
BotConnector bot;

@PluginStorage("scores")
Storage allScores;

Map<String, int> words = {};

@Start()
loadWordList() {
  plugin.httpClient.get("https://raw.githubusercontent.com/PolymorphicBot/words/master/positivity.json").then((response) {
    words = JSON.decode(response.body);
  });
}

Sentiment getNegativity(String phrase) {
  var noPunctuation = phrase.replaceAll(new RegExp(r"[^a-zA-Z ]+"), " ");
  var hits = 0;
  var w = [];
  var tokens = noPunctuation.toLowerCase().split(" ");
  
  for (var token in tokens) {
    if (words.containsKey(token)) {
      if (words[token] < 0) {
        hits -= words[token];
        w.add(token);
      }
    }
  }
  
  return new Sentiment(hits, hits / tokens.length, w);
}

Sentiment getPositivity(String phrase) {
  var noPunctuation = phrase.replaceAll(new RegExp(r"[^a-zA-Z ]+"), " ");
  var hits = 0;
  var w = [];
  var tokens = noPunctuation.toLowerCase().split(" ");
  
  for (var token in tokens) {
    if (words.containsKey(token)) {
      if (words[token] > 0) {
        hits += words[token];
        w.add(token);
      }
    }
  }
  
  return new Sentiment(hits, hits / tokens.length, w);
}

@OnMessage()
analyze(MessageEvent event) {
  var scores = allScores.getSubStorage("${event.network}:${event.user}");

  var positive = getPositivity(event.message);
  var negative = getNegativity(event.message);
  scores.addToDouble("negative", negative.score, defaultValue: 0.0);
  scores.addToDouble("positive", positive.score, defaultValue: 0.0);
}

@Command("checkon")
checkOn(CommandEvent event) {
  if (!event.hasOneArgument) {
    event.usage();
    return;
  }
  
  var user = allScores.getSubStorage("${event.network}:${event.user}");
  
  if (!user.has("positive")) {
    event.reply("No History Found", prefixContent: "Sentimental");
    return;
  }
  
  var positive = user.getDouble("positive");
  var negative = user.getDouble("negative");
  
  event.replyNotice("Score: ${positive - negative}");
  event.replyNotice("Positive: ${positive}", prefixContent: "Sentimental");
  event.replyNotice("Negative: ${negative}", prefixContent: "Sentimental");
}

@HttpEndpoint("/data.json")
jsonData(request, response) {
  var keys = allScores.keys;
  var map = <String, Map<String, Map<String, dynamic>>>{};
  
  for (var key in keys) {
    var split = key.split(":");
    var network = split[0];
    var user = split[1];
    
    if (!map.containsKey(network)) {
      map[network] = {};
    }
    
    var u = allScores.getSubStorage(key);
    
    map[network][user] = {
      "positive": u.getDouble("positive"),
      "negative": u.getDouble("negative"),
      "score": u.getDouble("positive") - u.getDouble("negative")
    };
  }
  
  var content = new JsonEncoder.withIndent("  ").convert(map);
  response.write(content);
  response.close();
}

class Sentiment {
  final int score;
  final num comparative;
  final List<String> words;
  
  Sentiment(this.score, this.comparative, this.words);
}
