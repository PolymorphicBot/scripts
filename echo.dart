import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("echo", description: "Repeats the Input")
echo(CommandEvent event) {
  event >> (input) => input;
}
