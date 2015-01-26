import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("explainshell")
explainShell(CommandEvent event) {
  if (event.args.isEmpty) {
    event.reply("> Usage: explainshell <command>");
  } else {
    event.reply("> http://explainshell.com/explain?cmd=${Uri.encodeComponent(event.args.join(" ")).replaceAll("%20", "+")}");
  }
}
