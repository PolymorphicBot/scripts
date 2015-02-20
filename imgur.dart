import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

const List<String> TOPICS = const [
  "unicorn",
  "funny",
  "dog",
  "cat",
  "fail"
];

@Command("imgur", description: "Search Imgur", prefix: "Imgur")
imgur(CommandEvent event) {
  var search = event.chooseAtRandom(TOPICS);
  
  if (event.hasArguments) {
    search = event.joinArguments();
  }
  
  return fetchJSON("https://api.imgur.com/3/gallery/search", headers: {
    "Authorization": "Client-ID 540678dd539a986"
  }, query: {
    "q": search
  }).then((json) {
    var images = json.data;
    
    if (images.isNotEmpty) {
      var image = event.chooseAtRandom(images);
      return image.link;
    } else {
      return "I've got nothing.";
    }
  }).catchError((e) {
    if (e is HttpError) {
      print(e.statusCode);
      print(e.response);
    }
  });
}
