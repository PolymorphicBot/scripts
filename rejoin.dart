import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

Scheduler scheduler = new Scheduler();
const Duration joinDelay = const Duration(seconds: 10);

@OnKick()
handleKick(KickEvent event) async {
  void rejoin() {
    event.bot.joinChannel(event.network, event.channel);
  }
  
  if (event.user == await event.bot.getBotNickname(event.network)) {
    if (event.reason.toLowerCase().contains("spam")) {
      scheduler.schedule(joinDelay, rejoin);
    } else {
      rejoin();
    }
  }
}