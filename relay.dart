import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@BotInstance()
BotConnector bot;
@PluginInstance()
Plugin plugin;

bool enabled = true;

@RemoteMethod()
void isEnabled(RemoteCall call) => call.reply(enabled);

@OnJoin()
void handleJoin(JoinEvent event) {
  if (!enabled) {
    return;
  }
  
  String user = event.user;
  String network = event.network;
  String channel = event.channel;
  
  bot.getNetworks().then((networks) {
    var sendTo = copy(networks);
    sendTo.remove(network);
    sendTo.forEach((net) {
      bot.sendMessage(net, channel, "[${network}] ${user} joined");
    });
  });
}

@OnPart()
void handlePart(PartEvent event) {
  if (!enabled) {
    return;
  }
  
  String user = event.user;
  String network = event.network;
  String channel = event.channel;
  
  bot.getNetworks().then((networks) {
    var sendTo = copy(networks);
    sendTo.remove(network);
    sendTo.forEach((net) {
      bot.sendMessage(net, channel, "[${network}] ${user} left");
    });
  });
}

@OnQuitPart()
void handleQuitPart(QuitPartEvent event) {
  if (!enabled) {
    return;
  }
  
  String user = event.user;
  String network = event.network;
  String channel = event.channel;
  
  bot.getNetworks().then((networks) {
    var sendTo = copy(networks);
    sendTo.remove(network);
    sendTo.forEach((net) {
      bot.sendMessage(net, channel, "[${network}] ${user} quit");
    });
  });
}

@OnMessage()
void handleMessage(MessageEvent event) {
  if (!enabled) {
    return;
  }
  
  var message = "[${event.network}] <-${event.from}> ${event.message}";

  bot.getNetworks().then((networks) {
    var sendTo = copy(networks);
    
    sendTo.remove(event.network);
    sendTo.forEach((network) {
      bot.sendMessage(network, event.target, message);
    });
  });
}

dynamic copy(dynamic input) {
  if (input is List) {
    return new List.from(input);
  } else if (input is Map) {
    return new Map.from(input);
  } else {
    throw new Exception("data type not able to be copied");
  }
}