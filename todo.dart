import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@BotInstance()
BotConnector bot;

@PluginInstance()
Plugin plugin;

@PluginStorage("todos")
Storage todos;

@Command("add-todo", description: "Add a TODO Item", prefix: "TODO", allowVariables: true)
addToDo(CommandEvent event, input) async {
  todos.addToList("${event.network}:${event.username}", input);
  event < "Added to TODO list as #${todos.getList("${event.network}:${event.username}").length}";
}

@Command("todos", description: "List TODO Items", prefix: "TODO")
listToDos(CommandEvent event) {
  event >> () async {
      var l = todos.getList("${event.network}:${event.username}", defaultValue: []);

      if (l.isEmpty) {
        event < "No TODOs.";
      } else {
        int i = 0;
        for (var t in l) {
          i++;
          event < "${i}. ${t}";
        }
      }
  };
}

@Command("remove-todo", description: "Remove a TODO Item", prefix: "TODO")
removeToDo(CommandEvent event) async {
  if (event.args.length != 1) {
    event << "Usage: remove-todo <number>";
    return;
  }

  var l = todos.getList("${event.network}:${event.username}");
  try {
    l.removeAt(int.parse(event.args[0]) - 1);
  } catch (e) {
    event < "Invalid TODO Number";
    return;
  }
  todos.setList("${event.network}:${event.username}", l);

  event < "Item #${event.args[0]} removed";
}