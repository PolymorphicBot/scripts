import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginStorage("storage")
Storage storage;

@OnMessage()
handleMessage(MessageEvent event) {
  storage.incrementInteger("messages_total");
  storage.incrementInteger("${event.network}_messages_total");

  if (event.target.startsWith("#")) {
    storage.incrementInteger("${event.network}_${event.target}_messages_total");
    storage.incrementInteger("${event.network}_${event.target}_user_${event.from}_messages_total");
  }
}

@OnCommand()
handleCommand(CommandEvent event) {
  storage.incrementInteger("${event.network}_commands_total");
  storage.incrementInteger("${event.network}_${event.channel}_commands_total");
  storage.incrementInteger("commands_total");
}

@Command("stats")
stats(CommandEvent event) {
  var msgsTotal = storage.getInteger("messages_total", defaultValue: 0);
  var cmdsTotal = storage.getInteger("commands_total", defaultValue: 0);
  var networkMsgsTotal = storage.getInteger("${event.network}_messages_total", defaultValue: 0);
  var networkCmdsTotal = storage.getInteger("${event.network}_commands_total", defaultValue: 0);
  var channelMsgsTotal = storage.getInteger("${event.network}_${event.channel}_messages_total", defaultValue: 0);
  var channelCmdsTotal = storage.getInteger("${event.network}_${event.channel}_commands_total", defaultValue: 0);

  event.replyNotice("Bot - Total Messages: ${msgsTotal}", prefix: true, prefixContent: "Statistics");
  event.replyNotice("Users - Total Command Runs: ${cmdsTotal}", prefix: true, prefixContent: "Statistics");
  event.replyNotice("Network - Total Messages: ${networkMsgsTotal}", prefix: true, prefixContent: "Statistics");
  event.replyNotice("Channel - Total Messages: ${channelMsgsTotal}", prefix: true, prefixContent: "Statistics");
  event.replyNotice("Network - Total Command Runs: ${networkCmdsTotal}", prefix: true, prefixContent: "Statistics");
  event.replyNotice("Channel - Total Command Runs: ${channelCmdsTotal}", prefix: true, prefixContent: "Statistics");

  {
    var users = <Map<String, dynamic>>[];
    storage.keys.where((it) => it.startsWith("${event.network}_${event.channel}_user_")).forEach((name) {
      users.add({
        "name": name.replaceAll("${event.network}_${event.channel}_user_", "").replaceAll("_messages_total", ""),
        "count": storage.getInteger(name, defaultValue: 0)
      });
    });

    users.sort((a, b) => b['count'].compareTo(a['count']));

    if (users.isNotEmpty) {
      var most = users.first['name'];
      var actives = (users.take(6).toList()..removeAt(0)).map((it) => it['name']);

      event.replyNotice("Most Active User on ${event.channel}: ${most}", prefix: true, prefixContent: "Statistics");

      if (actives.length > 1) {
        event.replyNotice("Active Users on ${event.channel}: ${actives.join(", ")}", prefix: true, prefixContent: "Statistics");
      }
    }
  }
}
