import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@BotInstance()
BotConnector bot;

@Command("commands")
commands(CommandEvent event) {
  bot.getCommands().then((commands) {
    DisplayHelpers.paginate(commands, 5, (page, items) {
      event.replyNotice("[${Color.BLUE}Commands${Color.RESET}] ${items.map((it) => it.name).join(', ')}");
    });
  });
}

@Command("command")
command(CommandEvent event) {
  if (event.args.length != 1) {
    event.reply("> Usage: command <cmd>");
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
