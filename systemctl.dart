import "dart:io";

import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;

const String CIRCLE = "\u25CF";

final String GREEN_CIRCLE = "${Color.GREEN}${CIRCLE}${Color.RESET}";
final String RED_CIRCLE = "${Color.RED}${CIRCLE}${Color.RESET}";
final String YELLOW_CIRCLE = "${Color.YELLOW}${CIRCLE}${Color.RESET}";

@Command("systemctl",
    description: "Manage System Services",
    permission: "manage",
    usage: "start/stop/restart/is-active/status <service>"
)
systemctl(CommandEvent event) {
  if (event.hasNoArguments) {
    event.usage();
    return;
  }
  
  var cmd = event.args[0];
  var args = event.dropArguments(1);
  
  if (cmd == "start") {
    if (args.length != 1) {
      event.usage();
      return;
    }
  
    ProcessHelper.run("sudo", ["systemctl", "start", args[0]]).then((result) {
      var exitCode = result.exitCode;
      
      if (exitCode != 0) {
        event.reply("Failed to start '${args[0]}'.", prefixContent: "Services");
        return;
      }
      
      event.reply("Started '${args[0]}'.", prefixContent: "Services");
    });
  } else if (cmd == "stop") {
    if (args.length != 1) {
      event.usage();
      return;
    }
  
    ProcessHelper.run("sudo", ["systemctl", "stop", args[0]]).then((result) {
      var exitCode = result.exitCode;
      
      if (exitCode != 0) {
        event.reply("Failed to stop '${args[0]}'.", prefixContent: "Services");
        return;
      }
      
      event.reply("Stopped '${args[0]}'.", prefixContent: "Services");
    });
  } else if (cmd == "restart") {
    if (args.length != 1) {
      event.usage();
      return;
    }
  
    ProcessHelper.run("sudo", ["systemctl", "restart", args[0]]).then((result) {
      var exitCode = result.exitCode;
      
      if (exitCode != 0) {
        event.reply("Failed to restart '${args[0]}'.", prefixContent: "Services");
        return;
      }
      
      event.reply("Restarted '${args[0]}'.", prefixContent: "Services");
    });
  } else if (cmd == "is-active") {
    if (args.length != 1) {
      event.usage();
      return;
    }
  
    ProcessHelper.run("sudo", ["systemctl", "is-active", args[0]]).then((result) {
      var exitCode = result.exitCode;
      
      if (exitCode != 0) {
        event.reply("'${args[0]}' is not running.", prefixContent: "Services");
        return;
      }
      
      event.reply("'${args[0]}' is running.", prefixContent: "Services");
    });
  } else if (cmd == "status") {
    if (args.length != 1) {
      event.usage();
      return;
    }
  
    ProcessHelper.getStdout("sudo", ["systemctl", "is-active", args[0]]).then((status) {
      status = status.trim();
      event.reply("Status: ${status}", prefixContent: "Services");
    });
  } else if (cmd == "waterfall") {
    if (args.isNotEmpty) {
      event.usage();
      return;
    }
    
    ProcessHelper.getStdout("sudo", ["systemctl", "list-units", "--no-pager", "--plain", "--all"]).then((output) {
      var statuses = parseUnitFilesList(output);

      DisplayHelpers.paginate(statuses.keys, 4, (page, items) {
        var buff = new StringBuffer();
        var first = true;
        for (var name in items) {
          if (first) {
            first = false;
          } else {
            buff.write(" | ");
          }

          var status = statuses[name];
          String icon = CIRCLE;

          if (status == "active") {
            icon = GREEN_CIRCLE;
          } else if (status == "inactive") {
            icon = YELLOW_CIRCLE;
          } else if (status == "failed") {
            icon = RED_CIRCLE;
          } else {
            icon = CIRCLE;
          }

          buff.write("${icon} ${name}");
        }

        event.replyNotice(buff.toString());
      });
    });
  } else {
    event.reply("Unknown Command", prefixContent: "Services");
  }
}

Map<String, String> parseUnitFilesList(String out) {
  var lines = out.split("\n")..removeAt(0);
  lines = lines.takeWhile((it) => !it.contains("Reflects whether the unit definition was properly loaded.")).map((it) {
    return it.replaceAll("${CIRCLE}", "").trim();
  }).toList();
  lines.removeWhere((it) => it.trim().isEmpty || it.trim() == " ");
  
  var map = {};
  for (var line in lines) {
    var parts = line.split(" ");
    parts.removeWhere((it) => it.trim().isEmpty || it.trim() == " ");
    var name = parts[0];
    var status = parts[2];
    if (!name.endsWith(".service") || name.contains("@") || name.startsWith("systemd-")) {
      continue;
    }
    
    map[name.substring(0, name.indexOf(".service"))] = status;
  }
  return map;
}