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
    
  event.getLastCommand(true).then((command) {
    if (command == null) {
      event.reply("No Command to Rerun.", prefixContent: "Rerun");
      return;
    }
    
    var args = command.split(" ");
    var cmd = args.removeAt(0);
    
    event.executeCommand(cmd, args);
  });
}