import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginInstance()
Plugin plugin;

@BotInstance()
BotConnector bot;

@PluginStorage("storage")
Storage storage;

const List<String> words = const [
  "shit",
  "ass",
  "fuck",
  "bitch",
  "fuckit",
  "dick",
  "cock",
  "pussy",
  "nigga",
  "nigger",
  "asswipe",
  "assfuck",
  "cunt",
  "shitfuck",
  "fuckshit",
  "shat",
  "shitting",
  "fucking"
];

bool hasCussing(String msg) {
  var w = (<String>[]..addAll(words)..addAll(storage.getList("words", defaultValue: []))).map((it) => it.toLowerCase().trim());
  
  msg = msg.toLowerCase().trim();
  
  return w.any((word) {
    return msg.startsWith("${word} ") || msg == word || msg.contains(" ${word} ") || msg.endsWith(" ${word}");
  });
}
