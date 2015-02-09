import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";
 
@Command("arch-wiki", description: "Search the Arch Linux Wiki")
archWiki(event) => event >> (input) {
  return event.fetchJSON("https://wiki.archlinux.org/api.php?action=query&prop=info&inprop=url&format=json&titles=${Uri.encodeComponent(input)}").then((json) {
    if (json.pages.isEmpty || json.pages.containsKey("-1")) {
      return "> No Wiki Page Found.";
    } else {
      return "> ${json.pages[json.pages.keys.first].fullurl}";
    }
  });
};
