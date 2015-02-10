import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("catfacts", description: "Cat Facts", prefix: "Cat Facts")
catfacts(CommandEvent event) => event << () async {
  var json = await event.fetchJSON("http://catfacts-api.appspot.com/api/facts?number=1");
  return json.facts[0];
};