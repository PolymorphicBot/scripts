import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

const String APP_ID = "2982LV-6WP5YYAWLQ";

@Command("w", description: "Wolfram Alpha", prefix: "Wolfram")
w(String input) => wolfram(input);

@Command("wolfram", description: "Wolfram Alpha", prefix: "Wolfram")
wolfram(String input) async {
  var url = "http://api.wolframalpha.com/v2/query?output=json&input=${Uri.encodeComponent(input)}&appid=${APP_ID}";

  try {
    var json = await fetchJSON(url);

    if (json.error != null) {
      return json.error.msg;
    }

    var result = json.queryresult;

    if (result.pods == null) {
      var dym = result.didyoumeans;
      if (dym != null && dym.isNotEmpty) {
        var word = dym[0].val;
        return "Did you mean ${word}?";
      } else {
        return "No Result Found.";
      }
    }

    var n = result.pods
      .firstWhere((x) =>
        x.title != "Input interpretation" && x.title != "Input", orElse: () => null);

    if (n != null) {
      var r = n.subpods[0].plaintext;
      var split = r.split("\n");
      if (split.length > 5) {
        return split.take(5).join("\n");
      } else {
        return r;
      }
    }
  } catch (e) {
    return "Failed to get output.";
  }

  return "Pod is not yet supported.";
}
