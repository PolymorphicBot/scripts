import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@BotInstance()
BotConnector bot;

@PluginInstance()
Plugin plugin;

@PluginStorage("commands")
Storage storage;

@Command("addtxtcmd",
    permission: "add",
    description: "Adds a Text Command",
    usage: "<command> <text>",
    allowVariables: true)
addtxtcmd(CommandEvent event) {
  if (event.args.length < 2) {
    event.reply("Usage: addtxtcmd <command> <text>",
        prefixContent: "Text Commands");
  } else {
    var cmd = event.args[0];
    var text = event.args.sublist(1).join(" ");
    storage.setString(cmd, text);
    event.reply("Command Added", prefixContent: "Text Commands");
  }
}

@Command("removetxtcmd",
    permission: "remove",
    description: "Removes a Text Command",
    usage: "<command>")
removetxtcmd(CommandEvent event) {
  if (event.args.length != 1) {
    event.reply("Usage: removetxtcmd <command>",
        prefixContent: "Text Commands");
  } else {
    var cmd = event.args[0];
    storage.remove(cmd);
    event.reply("Command Removed", prefixContent: "Text Commands");
  }
}

@Command("listtxtcmds", permission: "list", description: "Lists Text Commands")
listtxtcmds(CommandEvent event) {
  var globals = storage.keys.where((it) {
    return !it.contains(" ");
  }).toList();

  DisplayHelpers.paginate(globals, 8, (page, items) {
    event.reply("${items.join(", ")}", prefixContent: "Text Commands");
  });
}

@Command("addchannelcmd",
    permission: "channel.add",
    description: "Adds a Channel Command",
    usage: "<command> <text>",
    allowVariables: true)
addchannelcmd(CommandEvent event) {
  if (event.args.length < 2) {
    event.reply("Usage: addchannelcmd <command> <text>",
        prefixContent: "Channel Commands");
  } else {
    var cmd = event.args[0];
    var text = event.args.sublist(1).join(" ");
    storage.setString(event.network + " " + event.channel + " " + cmd, text);
    event.reply("Command Added", prefixContent: "Channel Commands");
  }
}

@Command("removechannelcmd",
    permission: "channel.remove",
    description: "Removes a Channel Command",
    usage: "<command>")
removechannelcmd(CommandEvent event) {
  if (event.args.length != 1) {
    event.reply("Usage: removechannelcmd <command>",
        prefixContent: "Channel Commands");
  } else {
    var cmd = event.args[0];
    storage.remove(event.network + " " + event.channel + " " + cmd);
    event.reply("Command Removed", prefixContent: "Channel Commands");
  }
}

@Command("listchannelcmds",
    permission: "channel.list", description: "Lists Channel Commands")
listchannelcmds(CommandEvent event) {
  var ours = storage.keys.where((it) {
    return it.startsWith("${event.network} ${event.channel} ");
  }).map((it) => it.split(" ").last).toList();

  DisplayHelpers.paginate(ours, 8, (page, items) {
    event.reply("${items.join(", ")}", prefixContent: "Channel Commands");
  });
}

@Command("addgchannelcmd",
    permission: "channel.global.add",
    description: "Adds a Global Channel Command",
    usage: "<command> <text>",
    allowVariables: true)
addgchannelcmd(CommandEvent event) {
  if (event.args.length < 2) {
    event.reply("Usage: addgchannelcmd <command> <text>",
        prefixContent: "Global Channel Commands");
  } else {
    var cmd = event.args[0];
    var text = event.args.sublist(1).join(" ");
    storage.setString(event.channel + " " + cmd, text);
    event.reply("Command Added", prefixContent: "Global Channel Commands");
  }
}

@Command("removegchannelcmd",
    permission: "channel.global.remove",
    description: "Removes a Global Channel Command",
    usage: "<command>")
removegchannelcmd(CommandEvent event) {
  if (event.args.length != 1) {
    event.reply("Usage: removegchannelcmd <command>",
        prefixContent: "Global Channel Commands");
  } else {
    var cmd = event.args[0];
    storage.remove(event.channel + " " + cmd);
    event.reply("Command Removed", prefixContent: "Global Channel Commands");
  }
}

@Command("listgchannelcmds",
    permission: "channel.global.list",
    description: "Lists Global Channel Commands")
listgchannelcmds(CommandEvent event) {
  var ours = storage.keys.where((it) {
    return it.startsWith("${event.channel} ");
  }).map((it) => it.split(" ").last).toList();

  DisplayHelpers.paginate(ours, 8, (page, items) {
    event.reply("${items.join(", ")}",
        prefixContent: "Global Channel Commands");
  });
}

@OnCommand()
handleTextCommand(CommandEvent event) {
  String value = storage.getString("${event.command}");

  if (value != null) {
    event.reply("> ${value}", prefix: false);
  } else if ((value = storage.getString(
      "${event.network} ${event.channel} ${event.command}")) != null) {
    event.reply("> ${value}", prefix: false);
  } else if ((value = storage.getString("${event.channel} ${event.command}")) !=
      null) {
    event.reply("> ${value}", prefix: false);
  }
}
