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
    var result = json.queryresult;

    if (result.error != null) {
      return result.error.msg;
    }

    if (result.pods == null) {
      var dym = result.didyoumeans;
      if (dym != null && dym.isNotEmpty) {
        var word = dym[0].val;
        return "Did you mean ${word}?";
      } else {
        return "No Result Found.";
      }
    }

    var pods = new SimpleMap({});

    for (var pod in result.pods) {
      pods[pod.title] = pod;
    }

    var plainPods = [
      "Result",
      "Decimal approximation",
      "Response",
      "Definitions",
      "Definition",
      "Chemical names and formulas",
      "Basic information",
      "Power of 10 representation",
    ];

    for (var p in plainPods) {
      if (pods.containsKey(p)) {
        var r = pods[p].subpods[0].plaintext;
        var split = r.split("\n");
        if (split.length > 5) {
          return split.take(5).join("\n");
        } else {
          return r;
        }
      }
    }
  } catch (e) {
    return "Failed to get output.";
  }

  return "Pod is not yet supported.";
}
