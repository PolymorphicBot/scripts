import "dart:convert";
import "package:polymorphic_bot/plugin.dart";

Map<String, dynamic> data;

@BotInstance()
BotConnector bot;
@PluginInstance()
Plugin plugin;

@Start()
fetchData() {
  plugin.httpClient.get("https://developer.android.com/about/dashboards/index.html").then((response) {
    var body = response.body;
  
    var start = body.indexOf("var VERSION_DATA =\n[");
    var end = body.indexOf("];", start);
    var json = body.substring(start + "var VERSION_DATA =\n[".length, end);
    data = JSON.decode(json);
  });
}

@Command("android", description: "Android Information", usage: "distribution")
android(event) {
  if (event.hasNoArguments) {
    event.usage();
    return;
  }
  
  var m = data["data"];
  
  var cmd = event.args[0];
  var args = event.dropArguments(1);
  
  if (cmd == "distribution") {
    for (var it in m) {
      event.replyNotice("${it['name']} (${it['api']}): ${it['perc']}%", prefixContent: "Android Distribution");
    }
  } else {
    event.usage();
    return;
  }
}
