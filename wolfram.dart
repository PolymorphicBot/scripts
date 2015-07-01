import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

const String APP_ID = "2982LV-6WP5YYAWLQ";

@Command("w", description: "Wolfram Alpha", prefix: "Wolfram")
w(CommandEvent event, String input) => wolfram(event, input);

@Command("wp", description: "Wolfram Alpha with Custom Pods", prefix: "Wolfram")
wp(CommandEvent event, String input) => wolfram(event, input);

@Command("wolfram", description: "Wolfram Alpha", prefix: "Wolfram")
wolfram(CommandEvent event, String input) async {
  var thing = input;
  String preferPod;

  if (event.command == "wp") {
    var regex = new RegExp(r'\"(.*)\" (.*)');

    if (regex.hasMatch(thing)) {
      var match = regex.firstMatch(full);
      preferPod = match.group(1);
      thing = match.group(2);
    }
  }
  var url = "http://api.wolframalpha.com/v2/query?output=json&input=${Uri.encodeComponent(thing)}&appid=${APP_ID}";

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
      .firstWhere((x) {
      if (preferPod != null) {
        return x.title == preferPod;
      }

      if (x.title != "Input interpretation" && x.title != "Input") {
        return true;
      }
      return false;
    }, orElse: () => null);

    if (n != null) {
      var msgs = [];
      var r = n.subpods[0].plaintext;
      msgs.add("${n.title}:");
      msgs.addAll(r.split("\n"));
      return msgs.take(5).join("\n");
    }
  } catch (e) {
    return "Failed to get output.";
  }

  return "Pod not found.";
}
