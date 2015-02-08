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
  event >> (type) async {
    if (!releaseTypes.containsKey(type)) {
      return "Unknown Release Type";
    }

    return event.fetchJSON("https://www.kernel.org/releases.json", type: ReleaseInfo).then((ReleaseInfo info) {
      var release = info.getByMoniker(type);

      return "[${Color.BLUE}Linux Release${Color.RESET}] ${Color.DARK_GREEN}${release.version} released on ${friendlyDate(release.timestamp)}${release.iseol == true ? " EOL" : ""}${Color.RESET}";
    });
  };
}

class LatestVersion {
  String version;
}

class ReleaseInfo {
  LatestVersion latest_version;
  List<Release> releases;

  Release getByMoniker(String name) {
    return releases.firstWhere((it) => it.moniker == name, orElse: () => null);
  }
}

class Release {
  bool iseol;
  String version;
  String moniker;
  String source;
  String pgp;
  Released released;
  String gitweb;
  String changelog;
  String diffview;
  PatchInfo patch;
  DateTime get timestamp => released.time;
}

class PatchInfo {
  String full;
  String incremental;
}

class Released {
  int timestamp;
  String isodate;

  DateTime get time => new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000 + new Duration(days: 1).inMilliseconds);
}