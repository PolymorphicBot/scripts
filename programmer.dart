import "dart:convert";
import "dart:math";

import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

const List<String> MESSAGES = const [
  "Whats the object-oriented way to become wealthy? Inheritence",
  "http://goo.gl/yqpviv",
  "http://goo.gl/pmMtg3",
  "http://goo.gl/QQAFEl",
  "Programming today is a race between software engineers striving to build bigger and better idiot-proof programs, and the universe trying to build bigger and better idiots. So far, the universe is winning.",
  "Most of you are familiar with the virtues of a programmer. There are three, of course: laziness, impatience, and hubris.",
  "There are two ways of constructing a software design. One way is to make it so simple that there are obviously no deficiencies. And the other way is to make it so complicated that there are no obvious deficiencies.",
  "Perl – The only language that looks the same before and after encryption.",
  "Beware of bugs in the above code; I have only proved it correct, not tried it.",
  "http://goo.gl/FmRYPK",
  "http://goo.gl/NXgW7y",
  "http://goo.gl/wV4hRM",
  "http://goo.gl/hDDqgA",
  "In order to understand recursion, you must first understand recursion.",
  "http://goo.gl/KWdfiW",
  "http://goo.gl/ylRwI6",
  "http://goo.gl/PQhiby",
  "http://goo.gl/rnAdhG",
  "Your momma's so fat, she can sit on a binary tree and flatten it to a linked list in O(1) time.",
  "\"Knock Knock\" => \"Who\'s there?\" => *Long Pause* => \"Java.\"",
  "http://goo.gl/CNqcJr",
  "http://goo.gl/Oji5x1",
  "http://goo.gl/g8lrWn"
];

@Command("programmer", description: "Programmer Stuff")
programmer() => MESSAGES;

@Command("jar", description: "Jars")
jar() => "http://goo.gl/pmMtg3";

@Command("defprogramming", description: "Gets a random quote from defprogramming.com")
defprogramming(event) => fetchHTML("http://www.defprogramming.com/random?r=${randomNumber()}").then(($) {
  String quote = $("meta[description]").attributes["description"];
  for (var seq in HTML_ESCAPES.keys) {
    quote = quote.replaceAll(seq, HTML_ESCAPES[seq]);
  }
  return quote;
});

const Map<String, String> HTML_ESCAPES = const {
  "&quot;": '"',
  "&amp;": "&",
  "&lt;": "<",
  "&gt;": ">",
  "&mdash;": "—"
};

randomNumber() => new Random().nextInt(999999);