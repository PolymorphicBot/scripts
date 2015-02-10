import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("qr", description: "Generate QR Codes", usage: "<input>", prefix: "QR")
qr(CommandEvent event, input) => shortenUrl("https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${Uri.encodeComponent(input)}");