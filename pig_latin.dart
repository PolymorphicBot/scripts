import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("pig-latin", allowVariables: true, description: "Pig Latin Generator")
pigLatin(input) {
  var words = input.split(" ");
  return words.map((it) => it.trim()).map((word) {
    word = word.toLowerCase();
    if (!VOWELS.any((it) => word.contains(it))) {
      return word;
    }
    var consonant = firstConsonant(word);
    return consonant != null ? word.replaceFirst(consonant, "") + consonant + "ay" : word;
  }).toList().join(" ");
}

const List<String> VOWELS = const ["a", "e", "i", "o", "u"];

String firstConsonant(String word) => new List.generate(word.length, (i) {
  return word[i];
}, growable: true).firstWhere((String it) => !VOWELS.contains(it.toLowerCase()), orElse: () => null);
