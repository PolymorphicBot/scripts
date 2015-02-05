import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

Map<String, String> releaseTypes = {
  "stable": "Stable",
  "mainline": "Mainline",
  "next": "Next",
  "longterm": "Longterm"
};

@Command("linux-release")
linuxRelease(CommandEvent event) {
  event.transform((type) {
    if (!releaseTypes.containsKey(type)) {
      return "Unknown Release Type";
    }
    
    return event.fetchJSON("https://www.kernel.org/releases.json").then((json) {
      var releases = json["releases"];
      
      for (var release in releases) {
        if (release["moniker"] == type) {
          return "${Color.DARK_GREEN}${release["version"]} released on ${friendlyDate(new DateTime.fromMillisecondsSinceEpoch(release["released"]["timestamp"] * 1000 + new Duration(days: 1).inMilliseconds))}${release["iseol"] == true ? " EOL" : ""}${Color.RESET}";
        }
      }
    });
  }, prefix: "Linux Release");
}