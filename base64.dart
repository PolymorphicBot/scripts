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
  
  try {
    if (event.args[0] == "encode") {
      var encoded = encode(input);
      event.reply("${encoded}", prefixContent: "Base64");
    } else if (event.args[0] == "decode") {
      var decoded = decode(input);
      event.reply("${decoded}", prefixContent: "Base64");
    }
  } on FormatException catch (e) {
    if (e.message.contains("Size of Base 64 characters in Input")) {
      event.reply("ERROR: Size of Base64 characters in the input must be a multiple of 4.", prefixContent: "Base64");
    } else {
      event.reply("ERROR: ${e.message}", prefixContent: "Base64");
    }
  }
}

@RemoteMethod()
String encode(String input) => CryptoUtils.bytesToBase64(input.codeUnits);

@RemoteMethod()
String decode(String input) => new String.fromCharCodes(CryptoUtils.base64StringToBytes(input));