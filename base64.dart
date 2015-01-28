import "package:polymorphic_bot/plugin.dart";
import "package:crypto/crypto.dart";

export "package:polymorphic_bot/plugin.dart";

@Command("base64", usage: "<encode/decode> <input>", description: "Base64 Encoding and Decoding")
base64(CommandEvent event) {
  if (event.argc < 2 || !(["encode", "decode"].contains(event.args[0]))) {
    event.usage();
    return;
  }
  
  var input = (new List<String>.from(event.args)..removeAt(0)).join(" ");
  
  if (event.args[0] == "encode") {
    var encoded = CryptoUtils.bytesToBase64(input.codeUnits);
    event.reply("${encoded}", prefixContent: "Base64");
  } else if (event.args[0] == "decode") {
    var decoded = new String.fromCharCodes(CryptoUtils.base64StringToBytes(input));
    event.reply("${decoded}", prefixContent: "Base64");
  }
}
