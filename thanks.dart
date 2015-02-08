import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";
 
const List<String> replies = const [
  "you're welcome",
  "no problem",
  "not at all",
  "don’t mention it",
  "it’s no bother",
  "it’s my pleasure",
  "my pleasure",
  "it’s all right",
  "it’s nothing",
  "think nothing of it",
  "sure",
  "sure thing"
];
 
@OnMessage(pattern: "thank you|thanks", regex: true, ping: true)
thanks(MessageEvent event) => event << replies.map((it) => "${event.user}: ${it}").toList();