import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;

@Command("git-version", description: "Git Version")
gitVersion(CommandEvent event) {
  if (event.hasArguments) {
    event.usage();
    return;
  }

  event.fetch("https://raw.githubusercontent.com/git/git/master/RelNotes").then((data) {
    var version = data.substring("Documentation/RelNotes/".length, data.length - 4);

    event.reply("Version: ${version}", prefixContent: "Git");
  });
}
