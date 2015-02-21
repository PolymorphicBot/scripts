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
    
    var args = command.split(" ");
    var cmd = args.removeAt(0);
    
    event.executeCommand(cmd, args);
  });
}
