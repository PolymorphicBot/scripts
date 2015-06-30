import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

const String APP_ID = "2982LV-6WP5YYAWLQ";

@Command("wolfram", description: "Wolfram Alpha")
wolfram(String input) async {
  var url = "http://api.wolframalpha.com/v2/query?output=json&input=${Uri.encodeComponent(input)}&appid=${APP_ID}";
  var json = await fetchJSON(url);
  var result = json.queryresult;
  try {
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

    if (pods.Definition != null) {
      return pods.Definition.subpods[0].plaintext;
    } else if (pods.Result != null) {
      return pods.Result.subpods[0].plaintext;
    }
  } catch (e) {
    return "Failed to get output.";
  }

  return "Pod is not yet supported.";
}
