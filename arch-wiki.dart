import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

const String URL = "https://wiki.archlinux.org/api.php?action=query&prop=info&inprop=url&format=json&titles=";

@Command("arch-wiki", description: "Search the Arch Linux Wiki", prefix: "Arch Wiki")
archWiki(input) async {
  var url = "${URL}${Uri.encodeComponent(input)}";
  var json = await fetchJSON(url);

  if (json.query.pages.isEmpty || json.query.pages.containsKey("-1")) {
    return "No Wiki Page Found.";
  } else {
    return "${json.query.pages[json.query.pages.keys.first]['fullurl']}";
  }
}
