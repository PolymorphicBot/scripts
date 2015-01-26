import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@BotInstance()
BotConnector bot;

@Command("commands")
commands(CommandEvent event) {
  bot.getCommands().then((commands) {
    DisplayHelpers.paginate(commands, 5, (page, items) {
      event.reply("> ${items.map((it) => it.name).join(', ')}");
    });
  });
}
