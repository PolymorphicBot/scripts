import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;

@Command("abstract", description: "Provides an abstraction of a topic.")
abstract(CommandEvent event, input) async {
  var url = "http://api.duckduckgo.com/?format=json&q=${Uri.encodeComponent(input)}";
  var json = await event.fetchJSON(url);
  var topic = json.RelatedTopics != null ? json.RelatedTopics[0] : null;

  if (json.AbstractText != null) {
    event << json.AbstractText;

    if (json.AbstractURL != null) {
      event << json.AbstractURL;
    }
  } else if (topic != null && !(new RegExp("\/c\/").hasMatch(topic.FirstURL))) {
    event << topic.text;
    event << topic.FirstURL;
  } else if (json.Definition != null) {
    event << json.Definition;
    if (json.DefinitionURL != null) {
      event << json.DefinitionURL;
    }
  } else {
    return "I don't know anything about that.";
  }
}
