import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;

@Command("systemctl", description: "Manage System Services", permission: "manage", usage: "start/stop/restart <service>")
systemctl(CommandEvent event) {
  if (event.hasNoArguments) {
    event.usage();
    return;
  }
  
  var cmd = event.args[0];
  var args = event.dropArguments(1);
  
  if (cmd == "start") {
    if (args.length != 1) {
      event.usage();
      return;
    }
  
    ProcessHelper.run("sudo", ["systemctl", "start", args[0]]).then((result) {
      var exitCode = result.exitCode;
      
      if (exitCode != 0) {
        event.reply("Failed to start '${args[0]}'.", prefixContent: "Services");
        return;
      }
      
      event.reply("Started '${args[0]}'.", prefixContent: "Services");
    });
  } else if (cmd == "stop") {
    if (args.length != 1) {
      event.usage();
      return;
    }
  
    ProcessHelper.run("sudo", ["systemctl", "stop", args[0]]).then((result) {
      var exitCode = result.exitCode;
      
      if (exitCode != 0) {
        event.reply("Failed to stop '${args[0]}'.", prefixContent: "Services");
        return;
      }
      
      event.reply("Stopped '${args[0]}'.", prefixContent: "Services");
    });
  } else if (cmd == "restart") {
    if (args.length != 1) {
      event.usage();
      return;
    }
  
    ProcessHelper.run("sudo", ["systemctl", "restart", args[0]]).then((result) {
      var exitCode = result.exitCode;
      
      if (exitCode != 0) {
        event.reply("Failed to restart '${args[0]}'.", prefixContent: "Services");
        return;
      }
      
      event.reply("Restarted '${args[0]}'.", prefixContent: "Services");
    });
  } else {
    event.reply("Unknown Command", prefixContent: "Services");
  }
}
