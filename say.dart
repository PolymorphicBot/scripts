import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("say")
say(CommandEvent event) => event.transform((input) => input, noSign: true);