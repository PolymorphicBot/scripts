import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("cowsay", description: "What does the cow say?")
cowsay(input) => fetch("http://cowsay.morecode.org/say", query: {
  "text": input
});
