import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

import "package:dslink/dslink.dart";

@BotInstance()
BotConnector bot;

final RegExp VALUE_REGEX = new RegExp(r'(\"(.+)\"|[^ ]+) (\"(.+)\"|.+)');

class PathValuePair {
  final String path;
  final dynamic value;

  PathValuePair(this.path, this.value);
}

PathValuePair parsePathValuePair(CommandEvent event, String input, [bool flipped = false]) {
  if (!VALUE_REGEX.hasMatch(input)) {
    return null;
  }

  var match = VALUE_REGEX.firstMatch(input);

  var a = match[2] == null ? match[1] : match[2];
  var b = match[3];

  var path = flipped ? b : a;
  var value = flipped ? a : b;

  path = getAliasOrPath(event, path);

  return new PathValuePair(path, value);
}

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

  await link.onRequesterReady;

  StorageContainer meta = bot.plugin.getStorage("metadata");
  for (var key in meta.keys) {
    StorageContainer metas = meta.getSubStorage(key);
    List<String> parts = key.split(":");
    String network = parts[0];
    String user = parts.skip(1).join(":");
    if (user.startsWith("#")) {
      continue;
    }

    for (var m in metas.keys) {
      if (!m.startsWith("subscriptions::")) {
        continue;
      }

      var nick = m.split("::").skip(1).join("::");
      await doSubscribeToValue(network, user, nick, metas.getString(m));
    }
  }
}

@Command("dsa-html", description: "Generate an HTML Url to a DSA node", usage: "<path>", prefix: "DSA")
getHtmlUrl(CommandEvent event, String input) {
  input = getAliasOrPath(event, input);

  if (config.has("html_url_template")) {
    var template = config.getString("html_url_template");
    return template.replaceAll("{path}", Uri.encodeFull(input));
  } else {
    return "Unsupported.";
  }
}

String getAliasOrPath(CommandEvent event, String path) {
  var meta = event.getChannelMetadata();
  if (meta.has("alias::${path}")) {
    return meta.getString("alias::${path}");
  } else {
    return path;
  }
}

Map<String, ReqSubscribeListener> subscribeListeners = {};

doSubscribeToValue(String network, String user, String name, String path) async {
  RemoteNode node = await link.requester
    .getRemoteNode(path)
    .timeout(const Duration(seconds: 3), onTimeout: () => null);

  var isFirst = true;

  print("[DSA] ${user} on ${network} subscribes to ${path} as ${name}");

  subscribeListeners["${network}:${user}:${name}:${path}"] = link.requester.subscribe(path, (ValueUpdate update) async {
    if (isFirst) {
      isFirst = false;
      return;
    }

    var val = update.value.toString();

    if (update.value is double) {
      val = (update.value as double).toStringAsFixed(2);
    }

    if (node.attributes.containsKey("@unit")) {
      var unit = node.attributes["@unit"];
      if (unit == "%") {
        val += "%";
      } else {
        val += " ${unit}";
      }
    }

    bot.sendNotice(network, user, "[${Color.BLUE}${name}${Color.RESET}] ${val}");
  });
}

@Command("dsa-subscribe", description: "Subscribe to DSA Values", usage: "<nickname> <path>", prefix: "DSA")
subscribeToValue(CommandEvent event, String input) async {
  var pair = parsePathValuePair(event, input, true);

  if (pair == null) {
    return "ERROR: Bad Command Input.";
  }

  var settings = event.getUserMetadata();
  var key = "subscriptions::${pair.value}";
  if (settings.has(key)) {
    return "ERROR: Subscription called '${pair.value}' already exists.";
  }
  settings.setString(key, pair.path);
  await doSubscribeToValue(event.network, event.user, pair.value, pair.path);
  return "Subscribed.";
}

@Command("dsa-alias", description: "Alias DSA Path", usage: "<name> <path>", prefix: "DSA Aliases")
aliasPath(CommandEvent event, String input) {
  var pair = parsePathValuePair(event, input, true);

  if (pair == null) {
    return "ERROR: Bad Command Input.";
  }

  var data = event.getChannelMetadata();
  if (data.has("alias::${pair.value}")) {
    return "Alias named '${pair.value}' already exists.";
  }
  data.setString("alias::${pair.value}", pair.path);
  return "Alias Set.";
}

@Command("dsa-unalias", description: "Remove an alias to a DSA Path", usage: "<name>", prefix: "DSA Aliases")
unaliasPath(CommandEvent event, String input) {
  var data = event.getChannelMetadata();
  if (!data.has("alias::${input}")) {
    return "Alias '${input}' does not exist.";
  }
  data.remove("alias::${input}");
  return "Alias Removed.";
}

@Command("dsa-aliases", description: "List DSA Aliases", prefix: "DSA Aliases")
listAliases(CommandEvent event) {
  var data = event.getChannelMetadata();
  var out = [];
  for (var key in data.keys) {
    if (!key.startsWith("alias::")) {
      continue;
    }

    var name = key.split("alias::").last;
    out.add(name);
  }

  if (out.isNotEmpty) {
    DisplayHelpers.paginate(out, 5, (page, items) {
      event.reply(items.join(", "));
    });
  } else {
    return "No Aliases Found.";
  }
}

@Command("dsa-unsubscribe", description: "Unsubscribe from DSA Values", usage: "<nickname>", prefix: "DSA")
unsubscribeFromValue(CommandEvent event, String input) async {
  var settings = event.getUserMetadata();
  var key = "subscriptions::${input}";
  if (!settings.has(key)) {
    return "ERROR: No Such Subscription '${key}'";
  }
  var rkey = "${event.network}:${event.user}:${input}:${settings.getString(key)}";
  if (subscribeListeners.containsKey(rkey)) {
    subscribeListeners[rkey].cancel();
    subscribeListeners.remove(rkey);
  }

  settings.remove(key);

  return "Unsubscribed";
}

@Command("dsa-ls", description: "Get a Simple List of DSA Nodes", usage: "<path>", prefix: "DSA")
getSimpleList(CommandEvent event, String input) async {
  input = getAliasOrPath(event, input);

  var node = await link.requester
    .getRemoteNode(input)
    .timeout(const Duration(seconds: 3), onTimeout: () => null);

  if (node == null) {
    return "ERROR: Node not Found.";
  }

  var names = node.children.keys.where((k) {
    return node.children[k].configs[r"$disconnectedTs"] == null;
  }).join(", ");

  if (names.isEmpty) {
    return "No Children.";
  } else {
    return names;
  }
}

@Command("dsa-node", description: "Get a Simple Description of a DSA Node", usage: "<path>", prefix: "DSA")
getNodeInfo(CommandEvent event, String input) async {
  input = getAliasOrPath(event, input);
  RemoteNode node = await link.requester
    .getRemoteNode(input)
    .timeout(const Duration(seconds: 3), onTimeout: () => null);

  if (node == null) {
    return "ERROR: Node not Found.";
  }

  if (node.configs.containsKey(r"$disconnectedTs")) {
    return "ERROR: Node is disconnected.";
  }

  var childrenCount = node.children.keys.where((k) {
    return node.children[k].configs[r"$disconnectedTs"] == null;
  }).length;
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
getDsaValue(CommandEvent event, String input) async {
  input = getAliasOrPath(event, input);

  RemoteNode node = await link.requester
    .getRemoteNode(input)
    .timeout(const Duration(seconds: 3), onTimeout: () => null);

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
getDsaValues(CommandEvent event, String input) async {
  input = getAliasOrPath(event, input);

  RemoteNode node = await link.requester
    .getRemoteNode(input)
    .timeout(const Duration(seconds: 3), onTimeout: () => null);

  if (node == null) {
    return "ERROR: Node not Found.";
  }

  var out = [];

  for (RemoteNode child in node.children.values) {
    if (!child.configs.containsKey(r"$type")) {
      continue;
    }

    child = await link.requester.getRemoteNode(child.remotePath)
        .timeout(const Duration(seconds: 3), onTimeout: () => null);

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
getRealDsaValue(CommandEvent event, String input) async {
  input = getAliasOrPath(event, input);

  RemoteNode node = await link.requester
    .getRemoteNode(input)
    .timeout(const Duration(seconds: 3), onTimeout: () => null);

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
