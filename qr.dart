import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;

@Command("qr", description: "Generate QR Codes", usage: "<input>")
qr(CommandEvent event) => event.transform((input) {
  return shortenUrl("https://chart.googleapis.com/chart?chs=178x178&cht=qr&chl=${Uri.encodeComponent(input)}");
}, prefix: "QR");