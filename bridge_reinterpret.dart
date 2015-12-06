import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginStorage("config")
Storage config;

@BotInstance()
BotConnector bot;

@OnMessage()
onMessage(MessageEvent event) async {
  try {
    if (!config.isInList("bridges", "${event.network}:${event.user}")) {
      return;
    }

    String msg = event.message;
    if (!msg.contains("<") && !msg.contains(">")) {
      return;
    }

    String noColorsPlease = DisplayHelpers.clean(msg);
    String username = noColorsPlease.substring(noColorsPlease.indexOf("<") + 1, noColorsPlease.indexOf(">"));

    if (username.isEmpty) {
      return;
    }

    String realMessage = noColorsPlease.substring(username.length + 2).trimLeft();

    await bot.sendFakeMessage(event.network, username, event.channel, realMessage);
  } catch (e) {
  }
}
