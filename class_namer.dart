import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("class-namer", description: "Generates a Random Class Name", prefix: "Class Namer")
classNamer(event) async => (await event.fetch("http://www.classnamer.com/index.txt")).trim();
