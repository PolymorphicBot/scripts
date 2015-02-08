import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@BotInstance()
BotConnector bot;

@Command("commands", description: "Lists Commands")
commands(CommandEvent event) async {
  var commands = await bot.getCommands();
  DisplayHelpers.paginate(commands, 5, (page, items) {
    event < "[${Color.BLUE}Commands${Color.RESET}] ${items.map((it) => it.name).join(', ')}";
  });
}

@Command("command", description: "Gets Command Information", usage: "<cmd>")
command(CommandEvent event) async {
  if (event.argc != 1) {
    event.usage();
    return;
  }

  var cmd = await bot.getCommand(event.args[0]);

  if (cmd == null) {
    event.replyNotice("[${Color.BLUE}Command${Color.RESET}] No Such Command");
  } else {
    event.replyNotice("[${Color.BLUE}Command${Color.RESET}] Plugin: ${cmd.plugin}");

    if (cmd.description != null) {
      event.replyNotice("[${Color.BLUE}Command${Color.RESET}] Description: ${cmd.description}");
    }

    if (cmd.usage != null) {
      event.replyNotice("[${Color.BLUE}Command${Color.RESET}] Usage: ${cmd.usage}");
    }
  }
}
