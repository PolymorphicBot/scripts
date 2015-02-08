import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";
 
@Command("broken", allowVariables: true)
broken(CommandEvent event) {
  var who = event.joinArguments().trim();

  if (who.isEmpty) {
    who = "kaendfinger";
  }

  event.reply("${who} breaks all the things.");
}
