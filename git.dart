import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("git-version", description: "Git Version", prefix: "Git")
gitVersion() async {
  var $ = await fetchHTML("http://git-scm.com/");
  var version = $(".version").text.trim();
  var reldate = $(".release-date").text.trim();
  reldate = reldate.substring(1, reldate.length - 1);
  return "Version: ${version} (released on ${reldate})";
}

@Command("git-flag", description: "Random Git Flag", prefix: "Git")
gitFlag() async {
  var $ = await fetchHTML("http://git-scm.com/");
  var flag = $("#tagline").text.trim();
  return "git ${flag}";
}
