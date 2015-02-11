import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";
 
const List<String> insult = const [
  "That's not nice.",
  "RUDE!",
  "STFU!",
  "Go to hell."
];
 
@OnMessage(pattern: r"(is|is a|is a little|is very|be|very|is super|super|you)?(\ )?(buggy|suck|sucks|sucky|awful|aweful|smells|smelly|stinky|ugly|horrible|terrible|shithead|shitty|shit|crap|craphead|butthead|assfuck|asswipe)", regex: true, ping: true)
mean(MessageEvent event) => event << insult.map((it) => "${event.user}: ${it}").toList();
