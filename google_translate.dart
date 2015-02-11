import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

const Map<String, String> languages = const {
  "af": "Afrikaans",
  "sq": "Albanian",
  "ar": "Arabic",
  "az": "Azerbaijani",
  "eu": "Basque",
  "bn": "Bengali",
  "be": "Belarusian",
  "bg": "Bulgarian",
  "ca": "Catalan",
  "zh-CN": "Simplified Chinese",
  "zh-TW": "Traditional Chinese",
  "hr": "Croatian",
  "cs": "Czech",
  "da": "Danish",
  "nl": "Dutch",
  "en": "English",
  "eo": "Esperanto",
  "et": "Estonian",
  "tl": "Filipino",
  "fi": "Finnish",
  "fr": "French",
  "gl": "Galician",
  "ka": "Georgian",
  "de": "German",
  "el": "Greek",
  "gu": "Gujarati",
  "ht": "Haitian Creole",
  "iw": "Hebrew",
  "hi": "Hindi",
  "hu": "Hungarian",
  "is": "Icelandic",
  "id": "Indonesian",
  "ga": "Irish",
  "it": "Italian",
  "ja": "Japanese",
  "kn": "Kannada",
  "ko": "Korean",
  "la": "Latin",
  "lv": "Latvian",
  "lt": "Lithuanian",
  "mk": "Macedonian",
  "ms": "Malay",
  "mt": "Maltese",
  "no": "Norwegian",
  "fa": "Persian",
  "pl": "Polish",
  "pt": "Portuguese",
  "ro": "Romanian",
  "ru": "Russian",
  "sr": "Serbian",
  "sk": "Slovak",
  "sl": "Slovenian",
  "es": "Spanish",
  "sw": "Swahili",
  "sv": "Swedish",
  "ta": "Tamil",
  "te": "Telugu",
  "th": "Thai",
  "tr": "Turkish",
  "uk": "Ukrainian",
  "ur": "Urdu",
  "vi": "Vietnamese",
  "cy": "Welsh",
  "yi": "Yiddish"
};

@Command("translate")
translate(CommandEvent event) {
  if (event.hasNoArguments) {
    event.usage();
    return;
  }
  
  var input = event.joinArgs();
  var codes = (new List<String>.from(languages.keys)..addAll(languages.values)..sort()).join("|");
  var regex = new RegExp("(?:from (${codes}))?(?:(?: )?(?:in)?to (${codes}))? (.+)");
  
  var from = "auto";
  var to = "en";
  
  if (regex.hasMatch(input)) {
    var match = regex.firstMatch(input);
    
    String getLang(int group) {
      if (match.group(group) == null) return group == 1 ? from : to;
      
      return !languages.keys.contains(match.group(group)) ? languages.keys.firstWhere((it) => languages[it].toLowerCase() == match.group(group).toLowerCase(), orElse: () => match.group(group)) : match.group(group);
    }
    
    from = getLang(1);
    to = getLang(2);
    input = match.group(3);
  }
  
  var term = '"${input}"';
  
  fetchJSON("https://translate.google.com/translate_a/t", transform: (String json) {
    return json.replaceAll(",,,", ",").replaceAll(",,", ",");
  }, query: {
    "client": "t",
    "hl": "en",
    "multires": "1",
    "sc": "1",
    "sl": from,
    "ssel": "0",
    "tl": to,
    "tsel": "0",
    "uptl": "en",
    "text": term
  }, headers: {
    "User-Agent": "Mozilla/5.0"
  }).then((List<dynamic> response) {
    var language = languages[response[2]];
    String translated = response[0][0] is String ? response[0][0] : response[0][0][0];

    translated = '"' + translated.substring(1, translated.length - 1).trim() + '"';
    
    if (from == "auto") {
      if (language == null) {
        language = languages[to];
        var tmp = term;
        term = translated;
        translated = tmp;
      }
      
      event.reply("${term} is ${language} for ${translated}", prefixContent: "Google Translate");
    } else {
      event.reply("${term} in ${languages[from]} translates to ${translated} in ${languages[to]}", prefixContent: "Google Translate");
    }
  });
}
