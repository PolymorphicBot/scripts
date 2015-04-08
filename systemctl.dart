import "dart:async";
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
    usage: "<command>",
    prefix: "Services")
systemctl(CommandEvent event) async {
  var ctl = new SystemCTL(useSudo: true);
  if (event.hasNoArguments) {
    event.usage();
    return null;
  }

  var cmd = event.args[0];
  var args = event.dropArguments(1);

  if (cmd == "start") {
    if (args.length != 1) {
      return "Usage: ${cmd} <service>";
    }

    var service = args[0];
    var started = await ctl.start(service);

    if (started) {
      return "Started '${service}'";
    } else {
      return "Failed to start '${service}'";
    }
  } else if (cmd == "reload") {
    if (args.length != 1) {
      return "Usage: ${cmd} <service>";
    }

    var service = args[0];
    var reloaded = await ctl.reload(service);

    if (reloaded) {
      return "Reloaded '${service}'";
    } else {
      return "Failed to reload '${service}'";
    }
  } else if (cmd == "enable") {
    if (args.length != 1) {
      return "Usage: ${cmd} <service>";
    }

    var service = args[0];
    var enabled = await ctl.enable(service);

    if (enabled) {
      return "Enabled '${service}'";
    } else {
      return "Failed to enable '${service}'";
    }
  } else if (cmd == "disable") {
    if (args.length != 1) {
      return "Usage: ${cmd} <service>";
    }

    var service = args[0];
    var disabled = await ctl.disable(service);

    if (disabled) {
      return "Disabled '${service}'";
    } else {
      return "Failed to disable '${service}'";
    }
  } else if (cmd == "stop") {
    if (args.length != 1) {
      return "Usage: ${cmd} <service>";
    }

    var service = args[0];
    var stopped = await ctl.stop(service);

    if (stopped) {
      return "Stopped '${service}'";
    } else {
      return "Failed to stop '${service}'";
    }
  } else if (cmd == "restart") {
    if (args.length != 1) {
      return "Usage: ${cmd} <service>";
    }

    var service = args[0];
    var restarted = await ctl.restart(service);

    if (restarted) {
      return "Restarted '${service}'";
    } else {
      return "Failed to restart '${service}'";
    }
  } else if (cmd == "is-active") {
    if (args.length != 1) {
      return "Usage: ${cmd} <service>";
    }

    var service = args[0];
    var running = await ctl.isActive(service);

    if (running) {
      return "'${service}' is active.";
    } else {
      return "'${service}' is not active.";
    }
  } else if (cmd == "is-enabled") {
    if (args.length != 1) {
      return "Usage: ${cmd} <service>";
    }

    var service = args[0];
    var enabled = await ctl.isEnabled(service);

    if (enabled) {
      return "'${service}' is enabled.";
    } else {
      return "'${service}' is not enabled.";
    }
  } else if (cmd == "status") {
    if (args.length > 1) {
      return "Usage: ${cmd} [service]";
    }

    if (args.length == 1) {
      var service = args[0];
      var status = await ctl.getStatus(service);
      var color = getColorForStatus(status);
      return "Status: ${color}${status}${Color.RESET}";
    } else {
      var status = await ctl.getSystemStatus();
      var color = getColorForStatus(status);
      return "System Status: ${color}${status}${Color.RESET}";
    }
  } else if (cmd == "daemon-reload") {
    if (args.isNotEmpty) {
      return "Usage: ${cmd}";
    }

    var worked = await ctl.reloadDaemon();

    if (worked) {
      return "Reloaded.";
    } else {
      return "Failed to reload.";
    }
  } else if (cmd == "waterfall") {
    if (args.isNotEmpty) {
      return "Usage: ${cmd}";
    }

    var statuses = await ctl.getStatuses();

    DisplayHelpers.paginate(statuses.keys.toList(), 4, (page, items) {
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
  } else if (cmd == "help") {
    if (args.isNotEmpty) {
      return "Usage: ${cmd}";
    }

    event.replyNotice(
        "Commands: start/stop/restart/is-active/waterfall/status/daemon-reload",
        prefixContent: "Services");
  } else {
    event.reply("Unknown Command", prefixContent: "Services");
  }
}

@HttpEndpoint("/status.json")
statusJSON() async {
  var ctl = new SystemCTL(useSudo: true);
  var status = await ctl.getSystemStatus();

  return {
    "system": status,
    "units": await ctl.getStatuses()
  };
}

String getColorForStatus(String status) {
  var color = Color.DARK_GRAY;

  if (status == "degraded" ||
      status == "stopping" ||
      status == "failed" ||
      status == "not-found" ||
      status == "inactive") {
    color = Color.RED;
  } else if (status == "maintainence") {
    color = Color.DARK_GRAY;
  } else if (status == "running" || status == "active") {
    color = Color.GREEN;
  } else if (status == "initializing" || status == "starting") {
    color = Color.YELLOW;
  }

  return color;
}

class SystemCTL {
  static const String CIRCLE = "\u25CF";

  final bool useSudo;

  SystemCTL({this.useSudo: false});

  Future<bool> start(String service) async {
    return (await run(["start", service])).exitCode == 0;
  }

  Future<bool> stop(String service) async {
    return (await run(["stop", service])).exitCode == 0;
  }

  Future<bool> restart(String service) async {
    return (await run(["restart", service])).exitCode == 0;
  }

  Future<bool> reload(String service) async {
    return (await run(["reload", service])).exitCode == 0;
  }

  Future<bool> isActive(String service) async =>
      (await run(["is-active", service])).exitCode == 0;

  Future<bool> enable(String service) async {
    return (await run(["enable", service])).exitCode == 0;
  }

  Future<String> cat(String service) async {
    var result = await run(["cat", service]);

    if (result.exitCode != 0) {
      throw new Exception("No Service Found.");
    }

    return result.stdout;
  }

  Future<bool> disable(String service) async {
    return (await run(["disable", service])).exitCode == 0;
  }

  Future<bool> isEnabled(String service) async =>
      (await run(["is-enabled", service])).exitCode == 0;

  Future<String> getStatus(String service) async {
    return (await run(["is-active", service])).stdout.trim();
  }

  Future<Map<String, String>> getStatuses({bool all: false}) async {
    var result = await run(["list-units", "--no-pager", "--plain", "--all"]);
    var out = result.stdout.trim();
    return _parseUnitFilesList(out, all: all);
  }

  Future<String> getSystemStatus() async =>
      (await run(["is-system-running"])).stdout.trim();

  Future<bool> reloadDaemon() async {
    return (await run(["daemon-reload"])).exitCode == 0;
  }

  Future<ProcessResult> run(List<String> args) {
    return useSudo
        ? Process.run("sudo", ["systemctl"]..addAll(args))
        : Process.run("systemctl", args);
  }

  Map<String, String> _parseUnitFilesList(String out, {bool all: false}) {
    var lines = out.split("\n")..removeAt(0);
    lines = lines
        .takeWhile((it) => !it.contains(
            "Reflects whether the unit definition was properly loaded."))
        .map((it) {
      return it.replaceAll("${CIRCLE}", "").trim();
    }).toList();
    lines.removeWhere((it) => it.trim().isEmpty || it.trim() == " ");

    var map = {};
    for (var line in lines) {
      var parts = line.split(" ");
      parts.removeWhere((it) => it.trim().isEmpty || it.trim() == " ");
      var name = parts[0];
      var status = parts[2];

      if (!all && !name.endsWith(".service") || name.contains("@") || name.startsWith("systemd-")) {
        continue;
      }

      map[name] = status;
    }
    return map;
  }
}
