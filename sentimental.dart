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

@Command("checkon", prefix: "Sentimental")
checkOn(CommandEvent event) {
  if (event.args.length != 1) {
    return "Usage: checkon <user>";
  }

  var user = allScores.getSubStorage("${event.network}:${event.args[0]}");

  if (!user.has("positive") || !user.has("negative")) {
    return "No History Found";
  }

  var positive = user.getDouble("positive", defaultValue: 0.0);
  var negative = user.getDouble("negative", defaultValue: 0.0);

  return [
    "Score: ${positive - negative}",
    "Positive: ${positive}",
    "Negative: ${negative}"
  ];
}

@HttpEndpoint("/data.json")
jsonData() {
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
      "positive": u.getDouble("positive", defaultValue: 0.0),
      "negative": u.getDouble("negative", defaultValue: 0.0),
      "score": u.getDouble("positive", defaultValue: 0.0) - u.getDouble("negative", defaultValue: 0.0)
    };
  }

  return map;
}

class Sentiment {
  final int score;
  final num comparative;
  final List<String> words;

  Sentiment(this.score, this.comparative, this.words);
}
