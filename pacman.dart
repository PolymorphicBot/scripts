import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;

@Command("pacman", description: "Arch Linux Package Manager", usage: "stats")
pacman(CommandEvent event) {
  if (event.hasNoArguments) {
    event.usage();
    return;
  }
  
  var cmd = event.args[0];
  var args = event.dropArguments(1);
  
  if (cmd == "stats") {
    ProcessHelper.getStdout("pacman", ["-Qq"]).then((out) {
      var pkgs = out.split("\n");
      pkgs.removeWhere((it) => it.trim().isEmpty);
      var count = pkgs.length;
      event.reply("Installed Packages: ${count}", prefixContent: "Pacman");
    });
  } else if (cmd == "info") {
    if (args.length != 1) {
      event.reply("Usage: pacman info <package>", prefixContent: "Pacman");
      return;
    }
    
    var pkg = args[0];
    
    ProcessHelper.run("pacman", ["-Si", pkg]).then((result) {
      if (result.exitCode != 0) {
        event.reply("Package Not Found", prefixContent: "Pacman");
        return;
      }
      
      List<String> lines = result.stdout.split("\n");
      var version = lines.firstWhere((it) => it.startsWith("Version")).split(":").last.trim();
      var description = lines.firstWhere((it) => it.startsWith("Description")).split(":").last.trim();
      
      event.reply("Version: ${version}", prefixContent: "Pacman");
      event.reply("Description: ${description}", prefixContent: "Pacman");
    });
  } else {
    event.reply("Unknown Command", prefixContent: "Pacman");
  }
}
