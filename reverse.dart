import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("reverse")
reverse(CommandEvent event) =>
    event.transform((input) => new String.fromCharCodes(input.codeUnits.reversed));
