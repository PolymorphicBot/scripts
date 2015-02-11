import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("google", description: "Google Search", usage: "<query>", prefix: "Google")
google(input) async {
  var json = await fetchJSON("http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=${Uri.encodeComponent(query)}");
  var results = json.responseData.results;

  if (results.length == 0) {
    return "No Results Found!";
  } else {
    return "${results[0].titleNoFormatting} | ${results[0].unescapedUrl}";
  }
}
