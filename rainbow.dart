import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("rainbow", allowVariables: true)
rainbow(CommandEvent event) => event >> DisplayHelpers.rainbowColor;
