import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginInstance()
Plugin plugin;

@BotInstance()
BotConnector bot;

@Command("rerun", description: "Reruns the last command you executed")
rerun(CommandEvent event) {
  if (event.hasArguments) {
    event.usage();
    return;
  }
  
  List<BufferEntry> entries;
  
  event.getChannelBuffer().then((e) {
    entries = e;
    return bot.getPrefix(event.network, event.channel);
  }).then((prefix) {
    var e = entries.firstWhere((e) => e.network == event.network && e.user == e.user && e.message.startsWith(prefix), orElse: () => null);
    
    if (e == null) {
      event.reply("No Command to Rerun.", prefixContent: "Rerun");
      return;
    }
    
    var m = e.message;
    m = m.substring(prefix.length);
    
    var split = m.split(" ").toList(growable: true);
    
    var c = split.removeAt(0);
    var a = split;
    
    plugin.callMethod("emit", {
      "network": event.network,
      "target": event.channel,
      "from": event.user,
      "command": c,
      "args": a,
      "message": "${e.message}",
      "event": "command"
    });
  });
}