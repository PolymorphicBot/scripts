import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("hello")
hello(event) => event.reply("Hello!");
