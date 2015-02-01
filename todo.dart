import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@BotInstance()
BotConnector bot;

@PluginInstance()
Plugin plugin;

@PluginStorage("todos")
Storage todos;

@Command("add-todo", allowVariables: true)
addToDo(CommandEvent event) {
  if (event.args.isEmpty) {
    event.reply("> Usage: add-todo <message>");
    return;
  }

  todos.addToList("${event.network}:${event.user}", event.args.join(" "));
  event.replyNotice("Added to TODO list as #${todos.getList("${event.network}:${event.user}").length}", prefixContent: "TODO");
}

@Command("todos")
listToDos(CommandEvent event) {
  var l = todos.getList("${event.network}:${event.user}", defaultValue: []);

  if (l.isEmpty) {
    event.replyNotice("No TODOs.", prefixContent: "TODO");
  } else {
    int i = 0;
    for (var t in l) {
      i++;
      event.replyNotice("${i}. ${t}", prefixContent: "TODO");
    }
  }
}

@Command("remove-todo")
removeToDo(CommandEvent event) {
  if (event.args.length != 1) {
    event.reply("> Usage: remove-todo <number>");
    return;
  }

  var l = todos.getList("${event.network}:${event.user}");
  try {
    l.removeAt(int.parse(event.args[0]) - 1);
  } catch (e) {
    event.replyNotice("Invalid TODO Number", prefixContent: "TODO");
    return;
  }
  todos.setList("${event.network}:${event.user}", l);

  event.replyNotice("Item #${event.args[0]} removed", prefixContent: "TODO");
}