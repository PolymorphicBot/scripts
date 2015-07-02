import "dart:async";
import "dart:collection";
import "dart:io";

import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;
@PluginStorage("logging")
Storage storage;

Timer _timer;

@Command("stop-log", permission: "stop-log")
stopLog(CommandEvent event) {
  if (event.args.length > 1) {
    event.reply("> Usage: stop-log [channel]");
    return;
  }

  var channel = "${event.network}:${event.args.length == 0 ? event.channel : event.args[0]}";

  if (storage.isInList("nolog", channel)) {
    event.reply("> ERROR: Logging is not enabled for ${event.args.length == 0 ? event.channel : event.args[0]}.");
    return;
  }

  storage.addToList("nolog", channel);

  var f = new File("logs/${event.network}/${(event.args.length == 0 ? event.channel : event.args[0]).substring(1)}.txt");
  if (f.existsSync()) {
    f.deleteSync();
  }

  event.reply("> Logging in ${event.args.length == 0 ? event.channel : event.args[0]} has been disabled.");
}

@Command("log-channel", permission: "log-channel")
logChannel(CommandEvent event) {
  if (event.args.length > 1) {
    event.reply("> Usage: log-channel [channel]");
    return;
  }

  var channel = "${event.network}:${event.args.length == 0 ? event.channel : event.args[0]}";

  if (!storage.isInList("nolog", channel)) {
    event.reply("> ERROR: Logging is already enabled for ${event.args.length == 0 ? event.channel : event.args[0]}.");
    return;
  }

  storage.removeFromList("nolog", channel);
  event.reply("> Logging in ${event.args.length == 0 ? event.channel : event.args[0]} has been enabled.");
}

@Command("flush-logs", permission: "flush-logs")
flushCommand(CommandEvent event) {
  flushLogs();
}

@Start()
void startTimer() {
  _timer = new Timer.periodic(new Duration(seconds: 5), (_) {
    flushLogs();
  });
}

void flushLogs() {
  var map = <String, List<LogEntry>>{};

  while (_queue.isNotEmpty) {
    var entry = _queue.removeFirst();
    var simpleName = "${entry.network}/${entry.channel.substring(1)}";

    if (map.containsKey(simpleName)) {
      map[simpleName].add(entry);
    } else {
      map[simpleName] = <LogEntry>[entry];
    }
  }

  for (var name in map.keys) {
    var file = new File("logs/${name}.txt");

    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    var content = map[name].map((entry) {
      return entry.format();
    }).join("\n") + "\n";

    file.writeAsStringSync(content, mode: FileMode.APPEND);
  }
}

const List<String> TRUE_VALUES = const["true", "1", "yes"];
const List<String> FALSE_VALUES = const ["false", "0", "no"];

@HttpEndpoint("/")
httpRoot(HttpRequest request) => HttpHelper.notFound(request);

@DefaultEndpoint()
httpDefault(HttpRequest request, HttpResponse response) async {
  var qp = request.uri.queryParameters;
  var segments = request.uri.pathSegments;

  if (segments.length == 2 && fileExists("logs/${segments[0]}/${segments[1]}")) {
    var file = new File("logs/${segments[0]}/${segments[1]}");
    var lines = await file.readAsLines();
    if (TRUE_VALUES.contains(qp["full"]) || (request.uri.hasQuery && request.uri.query.endsWith("full"))) {
      response.writeln(lines.join("\n"));
    } else {
      var end = lines.length;
      var start = end - 100;
      if (start < 0) start = 0;
      response.writeln(lines.getRange(start, end).join("\n"));
    }
    response.close();
  } else {
    HttpHelper.notFound(request);
  }
}

bool fileExists(String path) => new File(path).existsSync();

void addEntry(LogEntry entry) {
  if (storage.isInList("nolog", "${entry.network}:${entry.channel}")) {
    return;
  }

  _queue.add(entry);
}

@Shutdown()
void stopTimer() {
  if (_timer.isActive) {
    _timer.cancel();
  }
}

@OnJoin()
void handleJoin(JoinEvent event) {
  addEntry(new LogEntry(event.network, event.channel, "${event.user} joined"));
}

@OnPart()
void handlePart(PartEvent event) {
  addEntry(new LogEntry(event.network, event.channel, "${event.user} left"));
}

@OnAction()
void handleAction(ActionEvent event) {
  addEntry(new LogEntry(event.network, event.target, "* ${event.user} ${DisplayHelpers.clean(event.message)}"));
}

@OnNickChange()
void handleNickChange(NickChangeEvent event) {
  bot.getChannels(event.network).then((channels) {
    var c = channels.where((it) {
      var all = (new Set<String>()
        ..addAll(it.members)
        ..addAll(it.ops)
        ..addAll(it.voices)
        ..addAll(it.halfOps)
        ..addAll(it.owners));
      return all.contains(event.original) || all.contains(event.now);
    }).map((it) => it.name).toList();

    for (var m in c) {
      addEntry(new LogEntry(event.network, m, "${event.original} is now known as ${event.now}"));
    }
  }).catchError((e) {});
}

@OnMessage()
void handleMessage(MessageEvent event) {
  if (event.isPrivate) return;

  addEntry(new LogEntry(event.network, event.target, "<${event.from}> ${DisplayHelpers.clean(event.message)}"));
}

@OnQuitPart()
void handleQuitPart(QuitPartEvent event) {
  addEntry(new LogEntry(event.network, event.channel, "${event.user} quit"));
}

Queue<LogEntry> _queue = new Queue<LogEntry>();

class LogEntry {
  final String network;
  final String channel;
  final String message;
  final DateTime timestamp;

  LogEntry(this.network, this.channel, this.message) : timestamp = new DateTime.now();
  LogEntry.notNow(this.network, this.channel, this.message, this.timestamp);

  String format() {
    var m = timestamp.toString();
    m = m.substring(0, m.indexOf("."));
    return "[${m}] ${message}";
  }
}
