import "dart:typed_data";

import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

import "package:cipher/cipher.dart";
import "package:cipher/impl/base.dart";
import "package:crypto/crypto.dart" show CryptoUtils;

@Start()
start() => initCipher();

@Command("sha1")
sha1(CommandEvent event) => event.transform((input) => hash(input, "SHA-1"), prefix: "SHA-1");

@Command("sha3")
sha3(CommandEvent event) => event.transform((input) => hash(input, "SHA-3"), prefix: "SHA-3");

@Command("md5")
md5(CommandEvent event) => event.transform((input) => hash(input, "MD5"), prefix: "MD5");

@Command("sha256")
sha256(CommandEvent event) => event.transform((input) => hash(input, "SHA-256"), prefix: "SHA-256");

@Command("sha512")
sha512(CommandEvent event) => event.transform((input) => hash(input, "SHA-512"), prefix: "SHA-512");

String hash(String input, String name) {
  var digest = new Digest(name);
  var out = digest.process(createUint8ListFromString(input));
  return CryptoUtils.bytesToHex(out);
}

Uint8List createUint8ListFromString(String s) {
  var ret = new Uint8List(s.length);
  for (var i = 0; i < s.length; i++) {
    ret[i] = s.codeUnitAt(i);
  }
  return ret;
}
