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

@Command("dsa-ls", description: "Get a Simple List of DSA Nodes", usage: "<path>", prefix: "DSA")
getSimpleList(String input) async {
  var node = await link.requester.getRemoteNode(input).timeout(const Duration(seconds: 3), onTimeout: () => null);

  if (node == null) {
    return "ERROR: Node not Found.";
  }

  var names = node.children.keys.join(", ");

  if (names.isEmpty) {
    return "No Children.";
  } else {
    return names;
  }
}

@Command("dsa-node", description: "Get a Simple Description of a DSA Node", usage: "<path>", prefix: "DSA")
getNodeInfo(String input) async {
  var node = await link.requester.getRemoteNode(input).timeout(const Duration(seconds: 3), onTimeout: () => null);

  if (node == null) {
    return "ERROR: Node not Found.";
  }

  var childrenCount = node.children.keys.length;
  var path = new Path(node.remotePath);
  var name = node.configs.containsKey(r"$name") ? node.configs[r"$name"] : path.name;

  var out = [
    "Name: ${name}"
  ];

  if (node.configs[r"$type"] != null) {
    out.add("Value Type: ${node.configs[r"$type"]}");
  }

  if (childrenCount > 0) {
    out.add("${childrenCount} ${childrenCount == 1 ? 'child' : 'children'}");
  }

  return out.join(", ");
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

@Command("dsa-values", description: "Get multiple DSA Values", usage: "<path>", prefix: "DSA")
getDsaValues(String input) async {
  RemoteNode node = await link.requester.getRemoteNode(input).timeout(const Duration(seconds: 3), onTimeout: () => null);

  if (node == null) {
    return "ERROR: Node not Found.";
  }

  var out = [];

  for (RemoteNode child in node.children.values) {
    if (!child.configs.containsKey(r"$type")) {
      continue;
    }

    child = await link.requester.getRemoteNode(child.remotePath).timeout(const Duration(seconds: 3), onTimeout: () => null);

    if (child == null) {
      continue;
    }

    var path = new Path(child.remotePath);
    var name = child.configs.containsKey(r"$name") ? child.configs[r"$name"] : path.name;
    var update = await link.requester.getNodeValue(child.remotePath);
    var rval = update.value;

    String val = rval.toString();

    if (rval is double) {
      val = rval.toStringAsFixed(2);
    }

    if (child.attributes.containsKey("@unit")) {
      var unit = child.attributes["@unit"];
      if (unit == "%") {
        val += "%";
      } else {
        val += " ${unit}";
      }
    }

    out.add("${name}: ${val}");
  }

  return out.join("\n");
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