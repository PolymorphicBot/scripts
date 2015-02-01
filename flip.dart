import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("flip")
flip(CommandEvent event) {
  if (event.hasArguments) {
    event.usage();
    return;
  }
  
  event.reply("\u253B\u2501\u253B");
}