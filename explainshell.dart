import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("explainshell")
explainShell(input) => "> http://explainshell.com/explain?cmd=${Uri.encodeComponent(input).replaceAll("%20", "+")}";

