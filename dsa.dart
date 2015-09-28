import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

import "package:dslink/dslink.dart";

@PluginStorage("config")
Storage config;

const Map<String, dynamic> dependencies = const {
  "dslink": const {
    "git": "https://github.com/IOT-DSA/sdk-dslink-dart.git"
  }
};

LinkProvider link;

@Start()
start() async {
  String brokerUrl = config.getString("broker", defaultValue: "http://127.0.0.1:8080/conn");
  String linkName = config.getString("name", defaultValue: "PolymorphicBot");

  link = new LinkProvider(
    ["--broker=${brokerUrl}"],
    "${linkName}-",
    isRequester: true,
    isResponder: true,
    loadNodesJson: false
  );
  link.connect();
}

@Command("dsa-value", description: "Get DSA Value", usage: "<path>", prefix: "DSA")
getDsaValue(String input) async {
  RemoteNode node = await link.requester.getRemoteNode(input).timeout(const Duration(seconds: 3), onTimeout: () => null);

  if (node == null) {
    return "ERROR: Node not Found.";
  }

  var update = await link.requester.getNodeValue(input);
  var rval = update.value;

  String val = rval.toString();

  if (rval is double) {
    val = rval.toStringAsFixed(2);
  }

  if (node.attributes.containsKey("@unit")) {
    var unit = node.attributes["@unit"];
    if (unit == "%") {
      val += "%";
    } else {
      val += " ${unit}";
    }
  }

  return val;
}

@Command("dsa-rvalue", description: "Get Real DSA Value", usage: "<path>", prefix: "DSA")
getRealDsaValue(String input) async {
  RemoteNode node = await link.requester.getRemoteNode(input).timeout(const Duration(seconds: 3), onTimeout: () => null);

  if (node == null) {
    return "ERROR: Node not Found.";
  }

  var update = await link.requester.getNodeValue(input);
  var val = update.value.toString();

  if (node.attributes.containsKey("@unit")) {
    var unit = node.attributes["@unit"];
    if (unit == "%") {
      val += "%";
    } else {
      val += " ${unit}";
    }
  }

  return val;
}

@Shutdown()
shutdown() async {
  link.close();
}