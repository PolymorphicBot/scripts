import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;

Map<String, List<String>> cmds = {};

@Command("batch", description: "Batch Command Execution", usage: "start/add/execute")
batch(CommandEvent event) {
  if (event.hasNoArguments) {
    event.usage();
    return;
  }
  
  var c = event.args[0];
  var id = "${event.network}:${event.user}";
  
  if (c == "start") {
    if (cmds.containsKey(id)) {
      event.reply("Batch Execution list already started.", prefixContent: "Batch");
      return;
    }
    
    cmds[id] = [];
    event.reply("New Batch Execution List Created", prefixContent: "Batch");
  } else if (c == "add") {
    if (event.argc == 1) {
      event.reply("Usage: ${event.command} add <cmd>", prefixContent: "Batch");
      return;
    }
    
    if (!cmds.containsKey(id)) {
      event.reply("Batch Execution list has not been started.", prefixContent: "Batch");
      return;
    }
    
    var cmd = ((new List<String>.from(event.args))..removeAt(0)).join(" ");
    cmds[id].add(cmd);
    event.reply("Added.", prefixContent: "Batch");
  } else if (c == "execute") {
    if (!cmds.containsKey(id)) {
      event.reply("Batch Execution list has not been started.", prefixContent: "Batch");
      return;
    }
    
    var c = cmds.remove(id);
    if (c.isEmpty) {
      event.reply("Batch Execution list is empty.", prefixContent: "Batch");
      return;
    }
    
    var e = [];
    
    for (var x in c) {
      var s = x.split(" ");
      var f = s.first;
      var a = new List<String>.from(s)..removeAt(0);
      e.add({
        "network": event.network,
        "target": event.channel,
        "from": event.user,
        "command": f,
        "args": a,
        "message": ".${x}",
        "event": "command"
      });
    }
    
    for (var m in e) {
      plugin.callMethod("emit", m);
    }
  } else {
    event.reply("Invalid Command", prefixContent: "Batch");
  }
}