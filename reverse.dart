import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("reverse", allowVariables: true)
reverse(CommandEvent event) =>
    event.transform((input) => flip(input));
