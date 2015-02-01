import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginInstance()
Plugin plugin;

@BotInstance()
BotConnector bot;

@PluginStorage("storage")
Storage storage;

SubStorage get tracker => storage.getSubStorage("tracker");

const List<String> words = const [
  "shit",
  "ass",
  "fuck",
  "bitch",
  "fuckit",
  "dick",
  "cock",
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

@OnMessage()
handleMessage(MessageEvent event) {
  if (!hasCussing(event.message)) {
    return;
  }
  
  void warn(int i) {
    var m = "#${i}";
    
    bot.sendNotice(event.network, event.user, "[${Color.BLUE}Cussing${Color.RESET}] Warning: Cussing is not allowed in this channel. Strike #${i}.");
  }
  
  var x = tracker.incrementInteger("${event.network}:${event.user}");
  
  if (x == 3) {
    event.kickBanUser(reason: "Cussing");
    bot.sendNotice(event.network, event.user, "[${Color.BLUE}Cussing${Color.RESET}] You have been banned in ${event.channel} for cussing.");
    tracker.remove("${event.network}:${event.user}");
  } else {
    warn(x);
  }
}