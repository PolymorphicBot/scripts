import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@OnMessage()
bangBang(MessageEvent event) {
  if (event.message.trim() != "!!") return;
  
  event.getLastCommand(true).then((command) {
    if (command == null) {
      event.reply("No Command Found.", prefixContent: "BangBang");
      return;
    }
    
    event.getChannelPrefix().then((prefix) {
      var n = command.message.substring(prefix.length).split(" ");
      
      var c = n.first;
      var args = new List<String>.from(n)..removeAt(0);
      
      event.bot.plugin.callMethod("emit", {
        "network": event.network,
        "target": event.channel,
        "from": event.user,
        "command": c,
        "args": args,
        "message": "${command.message}",
        "event": "command"
      });
    });
  });
}