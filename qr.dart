import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;

@Command("qr", description: "Generate QR Codes", usage: "<input>")
qr(CommandEvent event) => event.transform((input) {
  return shortenUrl("https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${Uri.encodeComponent(input)}");
}, prefix: "QR");
