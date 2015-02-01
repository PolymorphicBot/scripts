import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;

@Command("google", description: "Google Search", usage: "<query>")
google(CommandEvent event) {
  if (event.hasNoArguments) {
    event.usage();
    return;
  }
  
  var query = event.joinArgs();
  
  event.fetchJSON("http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=${Uri.encodeComponent(query)}").then((json) {
    var results = json["responseData"]["results"];
    
    if (results.length == 0) {
      event.reply("> No Results Found!");
    } else {
      var result = results[0];
      event.reply("> ${result["titleNoFormatting"]} | ${result["unescapedUrl"]}");
    }
  });
}