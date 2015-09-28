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

@Command("dsa-value", description: "Get DSA Values", usage: "<path>")
getDsaValue(String input) async {
  var update = await link.requester.getNodeValue(input);
  return update.value.toString();
}

@Shutdown()
shutdown() async {
  link.close();
}