import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("catfacts", description: "Cat Facts", prefix: "Cat Facts")
catfacts(input) async => (await fetchJSON("http://catfacts-api.appspot.com/api/facts?number=1")).facts[0];