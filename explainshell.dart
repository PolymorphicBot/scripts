import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("explainshell", description: "Explains Shell Commands", prefix: "Explain Shell")
explainShell(input) => "http://explainshell.com/explain?cmd=${Uri.encodeComponent(input).replaceAll("%20", "+")}";
