import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@BotInstance()
BotConnector bot;

@Command("commands", description: "Lists Commands", prefix: "Commands")
commands(CommandEvent event) async {
  var commands = await bot.getCommands();
  DisplayHelpers.paginate(commands, 5, (page, items) {
    event < items.map((it) => it.name).join(', ');
  });
}

@Command("command", description: "Gets Command Information", usage: "<cmd>", prefix: "Command")
command(CommandEvent event, input) async {
  CommandInfo cmd = await bot.getCommand(input);
  
  if (cmd == null) {
    event < "No Such Command";
  } else {
    event < "Plugin: ${cmd.plugin}";
    
    if (cmd.description != null) {
      event < "Description: ${cmd.description}";
    }
    
    if (cmd.usage != null) {
      event < "Usage: ${cmd.usage}";
    }
  }
}
