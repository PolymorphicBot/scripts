import "dart:typed_data";

import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

import "package:cipher/cipher.dart";
import "package:cipher/impl/base.dart";
import "package:crypto/crypto.dart" show CryptoUtils;

@Start()
start() => initCipher();

@Command("md2", allowVariables: true, prefix: "MD2")
md2(input) => hash(input, "MD2");

@Command("md4", allowVariables: true, prefix: "MD4")
md4(input) => hash(input, "MD4");

@Command("md5", allowVariables: true, prefix: "MD5")
md5(input) => hash(input, "MD5");

@Command("sha1", allowVariables: true, prefix: "SHA-1")
sha1(input) => hash(input, "SHA-1");

@Command("sha3", allowVariables: true, prefix: "SHA-3")
sha3(input) => hash(input, "SHA-3");

@Command("sha224", allowVariables: true, prefix: "SHA-224")
sha224(input) => hash(input, "SHA-224");

@Command("sha256", allowVariables: true, prefix: "SHA-256")
sha256(input) => hash(input, "SHA-256");

@Command("sha384", allowVariables: true, prefix: "SHA-384")
sha384(input) => hash(input, "SHA-384");

@Command("sha512", allowVariables: true, prefix: "SHA-512")
sha512(input) => hash(input, "SHA-512");

@Command("tiger-hash", allowVariables: true, prefix: "Tiger")
tiger(input) => hash(input, "Tiger");

@Command("whirlpool-hash", allowVariables: true, prefix: "Whirlpool")
whirlpool(input) => hash(input, "Whirlpool");

String hash(String input, String name) =>
  CryptoUtils.bytesToHex(new Digest(name).process(new Uint8List.fromList(input.codeUnits)));