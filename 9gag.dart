import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("9gag")
ninegag(CommandEvent event) {
  var location = "http://9gag.com/random";

  return event.fetchHTML(location).then(($) {
    var e = selectElement($, ["div.badge-animated-container-animated img", "a img.badge-item-img"]);
    if (e == null) {
      return "Unable to find image.";
    }
    return e.attributes["src"];
  });
}

selectElement(HtmlDocument document, List<String> selectors) {
  for (var selector in selectors) {
    var img = document.document.querySelectorAll(selector);
    if (img != null && img.isNotEmpty) {
      return img.first;
    }
  }
}