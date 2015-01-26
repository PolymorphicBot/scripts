import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@BotInstance()
BotConnector bot;

@Command("commands", description: "Lists Commands")
commands(CommandEvent event) {
  bot.getCommands().then((commands) {
    DisplayHelpers.paginate(commands, 5, (page, items) {
      event.replyNotice("[${Color.BLUE}Commands${Color.RESET}] ${items.map((it) => it.name).join(', ')}");
    });
  });
}

@Command("command", description: "Gets Command Information", usage: "<cmd>")
command(CommandEvent event) {
  if (event.argc != 1) {
    event.usage();
    return;
  }

  bot.getCommand(event.args[0]).then((cmd) {
    if (cmd == null) {
      event.replyNotice("[${Color.BLUE}Command${Color.RESET}] No Such Command");
      return;
    }

    event.replyNotice("[${Color.BLUE}Command${Color.RESRT}] Plugin: ${cmd.plugin}");
    
    if (cmd.description != null) {
      event.replyNotice("[${Color.BLUE}Command${Color.RESET}] Description: ${cmd.description}");
    }

    if (cmd.usage != null) {
      event.replyNotice("[${Color.BLUE}Command${Color.RESET}] Usage: ${cmd.usage}");
    }
  });
}
