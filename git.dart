import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("git-version", description: "Git Version")
gitVersion(CommandEvent event) async {
  var data = await event.fetch("https://raw.githubusercontent.com/git/git/master/RelNotes");
  var version = data.substring("Documentation/RelNotes/".length, data.length - 4);
  return "[${Color.BLUE}Git${Color.RESET}] Version: ${version}";
}
