import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

import "package:quiver/pattern.dart";

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;

RegExp SEARCH_REPLACE = new RegExp(r"^s\/(.+?)\/(.*?)(?:\/?)([a-z]+?$|$)");

@OnMessage()
handleMessage(MessageEvent event) {
  if (!SEARCH_REPLACE.hasMatch(event.message)) {
    return;
  }
  
  var match = SEARCH_REPLACE.firstMatch(event.message);
  var search = match.group(1);
  var replace = match.group(2);
  var global = false;
  var escaped = true;
  var reverse = false;
  var capitalize = false;
  var caseSensitive = true;
  
  var mods = match.group(3) != null ? (new List<String>.generate(match.group(3).length, (i) => match.group(3)[i])) : [];
  
  loop: for (var mod in mods) {
    select: switch (mod) {
      case "n":
        escaped = false;
        break select;
      case "g":
        global = true;
        break select;
      case "r":
        reverse = true;
        break select;
      case "c":
        capitalize = true;
        break select;
      case "i":
        caseSensitive = false;
        break select;
      default:
        event.reply("Invalid Modifier: ${mod}", prefixContent: "RegExp");
        return;
    }
  }
  
  if (escaped) {
    search = escapeRegex(search);
  }
  
  if (reverse) replace = new String.fromCharCodes(replace.codeUnits.reversed);
  
  RegExp regex;
  
  try {
    regex = new RegExp(search, caseSensitive: caseSensitive);
  } on FormatException catch (e) {
    event.reply("Invalid Expression: ${e.message}", prefixContent: "RegExp");
    return;
  }
  
  bot.getChannelBuffer(event.network, event.channel).then((buffer) {
    for (var entry in buffer) {
      if (entry.message.startsWith("s/") || !(regex.hasMatch(entry.message) || entry.message == search)) {
        continue;
      }
      
      var msg = entry.message;
      
      if (!global) {
        var m = regex.firstMatch(msg);
        var c = m.groupCount;
        for (var i = 0; i <= c; i++) {
          replace = replace.replaceAll("{${i}}", m.group(i));
        }
      }
      
      var newmsg = global ? msg.replaceAll(regex, replace) : msg.replaceFirst(regex, replace);
      
      if (newmsg.length > 400) {
        newmsg = newmsg.substring(0, 400) + "...";
      }
      
      if (capitalize) {
        newmsg = newmsg[0].toUpperCase() + newmsg.substring(1);
      }
      
      var e = new BufferEntry(entry.network, entry.target, entry.user, newmsg);
      
      event.reply("${entry.user}: ${newmsg}", prefixContent: "RegExp");
      bot.appendChannelBuffer(e);
      return;
    }
    
    event.reply("Failed to find a match. (Modifiers: ${mods})", prefixContent: "RegExp");
  });
}