import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

const String KEY = "50b6a4b7956e5934de00d0e43c10b78e7a67da3eef3e50662";

@Command("wordnik", description: "Define a Word using Wordnik", usage: "<word>")
wordnik(CommandEvent event, input) => fetchJSON("http://api.wordnik.com/v4/word.json/${Uri.encodeComponent(input)}/definitions", query: {
  "limit": "1",
  "includeRelated": "true",
  "useCanonical": "true",
  "includeTags": "false",
  "api_key": KEY
}).then((json) => json.isEmpty ? "No Definition Found" : "${json[0].word}: ${json[0].text}");
