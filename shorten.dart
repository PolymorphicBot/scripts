import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

const String key = "AIzaSyBNTRakVvRuGHn6AVIhPXE_B3foJDOxmBU";

@Command("shorten", description: "Shorten URLs with Google URL Shortener", usage: "<url>", prefix: "Url Shortener")
shorten(CommandEvent event, input) async {
  try {
    var result = await event.postJSON("https://www.googleapis.com/urlshortener/v1/url?key=${key}", {
      "longUrl": input
    });

    var url = result.id;

    if (url == null) {
      return "Failed to Shorten Url.";
    } else {
      return url;
    }
  } catch (e) {
    return "Failed to Shorten Url.";
  }
}