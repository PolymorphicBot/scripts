import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("explainshell")
explainShell(CommandEvent event) {
  if (event.hasNoArguments) {
    event.usage();
    return;
  }
  
  event.reply("> http://explainshell.com/explain?cmd=${Uri.encodeComponent(event.joinArgs()).replaceAll("%20", "+")}");
}
