import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("hammer")
hammer(CommandEvent event) => event.reply(("\u25AC" * 4) + "\u258B");

@Command("banhammer")
banhammer(CommandEvent event) => event.reply("Somebody is bringing out the ban hammer! ${"\u25AC" * 4}\u258B Ò╭╮Ó");

@Command("hammertime")
hammertime(CommandEvent event) {
  event.reply("U can't touch ${event.hasArguments ? event.joinArgs() : "this"}.", prefix: false);
}
