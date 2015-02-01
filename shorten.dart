import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

const String key = "AIzaSyBNTRakVvRuGHn6AVIhPXE_B3foJDOxmBU";

@Command("shorten", description: "Shorten URLs with Google URL Shortener", usage: "<url>")
shorten(CommandEvent event) {
  if (!event.hasOneArgument) {
    event.usage();
    return;
  }
  
  event.postJSON("https://www.googleapis.com/urlshortener/v1/url?key=${key}", {
    "longUrl": event.args[0]
  }).then((value) {
    print(value);
    
    var url = value["id"];
    
    if (url == null) {
      event.reply("> Failed to Shorten URL.");
    } else {
      event.reply("> ${url}");
    }
  }).catchError((e) {
    print(e);
    event.reply("> Failed to Shorten URL.");
  });
}