import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

final Map<String, String> MODE_COMMANDS = {
  "op": "+o",
  "deop": "-o",
  "voice": "+v",
  "devoice": "-v",
  "quiet": "+q",
  "unquiet": "-q",
  "ban": "+b",
  "unban": "-b"
};

@BotInstance()
BotConnector bot;

@PluginInstance()
Plugin plugin;

@Command("join", description: "Join Channel", permission: "join")
join(CommandEvent event) {
  if (event.args.length > 2 || event.args.isEmpty) {
    return "> Usage: join [network] <channel>";
  }

  var network = event.args.length == 2 ? event.args[0] : event.network;
  var channel = event.args.length == 2 ? event.args[1] : event.args[0];

  bot.joinChannel(network, channel);
}

@Command("part", description: "Part Channel", permission: "part")
part(CommandEvent event) {
  if (event.args.length > 2) {
    return "> Usage: part [network] [channel]";
  }

  String network;
  String channel;

  if (event.argc == 0) {
    network = event.network;
    channel = event.channel;
  } else if (event.argc == 1) {
    network = event.network;
    channel = event.args[0];
  } else if (event.argc == 2) {
    network = event.args[0];
    channel = event.args[1];
  }

  if (channel == null) channel = event.channel;

  bot.partChannel(network, channel);
}

@Command("cycle", description: "Cycle Channel", permission: "cycle")
cycle(CommandEvent event) {
  if (event.args.length > 2) {
    return "> Usage: cycle [network] [channel]";
  }

  String network;
  String channel;

  if (event.argc == 0) {
    network = event.network;
    channel = event.channel;
  } else if (event.argc == 1) {
    network = event.network;
    channel = event.args[0];
  } else if (event.argc == 2) {
    network = event.args[0];
    channel = event.args[1];
  }

  if (channel == null) channel = event.channel;

  bot.partChannel(network, channel);
  bot.joinChannel(network, channel);
}

@Command("kick", description: "Kick a User", permission: "kick")
kick(CommandEvent event) {
  if (event.argc != 1) {
    return "> Usage: kick <user>";
  } else {
    bot.kick(event.network, event.channel, event.args[0]);
  }
}

@Command("kickban", description: "Kick + Ban a User", permission: "kick")
kickban(CommandEvent event) {
  if (event.argc != 1) {
    return "> Usage: kickban <user>";
  } else {
    bot.kickBan(event.network, event.channel, event.args[0]);
  }
}

@Command("topic", description: "Get/Set the Topic")
topic(CommandEvent event) async {
  if (event.hasNoArguments) {
    return await bot.getChannelTopic(event.network, event.channel);
  } else {
    bot.checkPermission(event.network, event.channel, event.user, "topic").then((_) {
      bot.setChannelTopic(event.network, event.channel, event.joinArguments());
    });
  }
}

@Command("topic-append", description: "Append to the Topic", permission: "topic-append")
appendTopic(CommandEvent event, input) async {
  var topic = await bot.getChannelTopic(event.network, event.channel);
  bot.setChannelTopic(event.network, event.channel, topic + " | " + input);
}

@Command("topic-prepend", description: "Prepend to the Topic", permission: "topic-prepend")
prependTopic(CommandEvent event, input) async {
  var topic = await bot.getChannelTopic(event.network, event.channel);
  bot.setChannelTopic(event.network, event.channel, " | " + input + topic);
}

@Command("networks", description: "Lists the Bot Networks", prefix: "Networks")
networks() async => (await bot.getNetworks()).join(", ");

@Command("plugins", description: "Lists the Bot Plugins", prefix: "Plugins")
plugins() async => (await bot.getPlugins()).join(", ");

@Start()
addModeCommands() {
  for (var cmd in MODE_COMMANDS.keys) {
    bot.command(cmd, (event) {
      if (event.args.length != 1) {
        event.reply("> Usage: ${cmd} <user>");
      } else {
        bot.mode(event.network, MODE_COMMANDS[event.command], channel: event.channel, user: event.args[0]);
      }
    }, permission: cmd, description: "${cmd[0].toUpperCase() + cmd.substring(1)} a User");
  }
}
