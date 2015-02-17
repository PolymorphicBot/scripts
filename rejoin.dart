import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@OnKick()
handleKick(KickEvent event) async {
  if (event.user == await event.bot.getBotNickname(event.network)) {
    event.bot.joinChannel(event.network, event.channel);
  }
}