import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("git-version", description: "Git Version", prefix: "Git")
gitVersion(CommandEvent event) async {
  var data = await event.fetch("https://raw.githubusercontent.com/git/git/master/RelNotes");
  var version = data.substring("Documentation/RelNotes/".length, data.length - 4);
  return "Version: ${version}";
}
