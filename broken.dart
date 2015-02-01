import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";
 
@Command("broken")
broken(CommandEvent event) {
  var who = event.args.isEmpty ? "kaendfinger" : event.args.join(' ');

  event.reply("${who} breaks all the things.");
}
