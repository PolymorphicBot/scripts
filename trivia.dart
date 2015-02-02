import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

List<Question> questions = [
  new Question("What is the name of George Bush's mom?", [
    "Barbara",
    "Dorothy",
    "Jenna",
    "Anna",
    "Hillary"
  ], "It's a family name."),
  new Question("What is kaendfinger's middle name?", [
    "Alexander",
    "Alex",
    "Kenneth",
    "Ken"
  ], "It's Great")
];

class Question {
  final String question;
  final List<String> answers;
  final String hint;
  
  Question(this.question, this.answers, this.hint);
}

@BotInstance()
BotConnector bot;

@PluginInstance()
Plugin plugin;

@Command("trivia")
trivia(CommandEvent event) {
  if (event.hasNoArguments) {
    event.usage();
    return;
  }
  
  void say(String msg) => event.reply(msg, prefixContent: "Trivia");
  
  var cmd = event.args[0];
  var args = event.dropArguments(1);
  var id = "${event.network}:${event.channel}";
  
  if (cmd == "start") {
    if (event.getChannelMetadata().getBoolean("game", defaultValue: false)) {
      say("Game already started.");
      return;
    }
    
    event.getChannelMetadata().setBoolean("game", true);
    say("Game started.");
    askQuestion(event, event.network, event.channel);
  } else if (cmd == "stop") {
    if (!event.getChannelMetadata().getBoolean("game", defaultValue: false)) {
      say("Game has not been started.");
      return;
    }
    
    event.getChannelMetadata().setBoolean("game", false);
    say("Game stopped.");
    clearMetadata(event);
    return;
  } else if (cmd == "answer") {
    if (!event.getChannelMetadata().getBoolean("game", defaultValue: false)) {
      say("Game has not been started.");
      return;
    }
    
    var q = questions[event.getChannelMetadata().getInteger("current")];
    
    if (args.length != 1) {
      say("Usage: trivia answer <letter>");
      return;
    }
    
    var l = args[0];
    
    if (!letters.contains(l)) {
      say("Invalid Choice.");
      return;
    }
    
    if (!event.getChannelMetadata().isInList("users", event.user)) {
      event.getChannelMetadata().addToList("users", event.user);
    }
    
    if (event.getUserMetadata(channelSpecific: true).getBoolean("answered", defaultValue: false)) {
      say("${event.user}: You have already answered.");
      return;
    }
    
    if (event.getChannelMetadata().getInteger("correct") == letters.indexOf(l)) {      
      say("${event.user}: Correct!");
      event.getUserMetadata(channelSpecific: true).incrementInteger("points", defaultValue: 0);
      event.getChannelMetadata().addToList("done", event.getChannelMetadata().getInteger("current"));
      askQuestion(event, event.network, event.channel);
    } else {
      say("${event.user}: Incorrect!");
      event.getUserMetadata(channelSpecific: true).setBoolean("answered", true);
    }
  } else if (cmd == "hint") {
    if (!event.getChannelMetadata().getBoolean("game", defaultValue: false)) {
      say("Game has not been started.");
      return;
    }
    
    var current = event.getChannelMetadata().getInteger("current");
    
    say(questions[current].hint);
  }
}

List<String> letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"];

clearMetadata(CommandEvent event) {
  var users = event.getChannelMetadata().getList("users", defaultValue: []);
  for (var u in users) {
    var e = event.getUserMetadata(user: u, channelSpecific: true);
    for (var k in e.keys) {
      e.remove(k);
    }
  }
  event.getChannelMetadata().keys.forEach((it) => event.getChannelMetadata().remove(it));
}

askQuestion(CommandEvent event, String network, String channel) {
  void say(String msg) => event.reply(msg, prefixContent: "Trivia");
  
  var m = 0;
  var done = event.getChannelMetadata().getList("done", defaultValue: []);
  
  Question q = event.chooseAtRandom(questions);
  
  while (done.contains(questions.indexOf(q))) {
    if (m >= questions.length + 50) {
      say("Game Complete!");
      var users = event.getChannelMetadata().getList("users", defaultValue: []);
      var winner;
      var x = [];
      for (var u in users) {
        var point = event.getUserMetadata(user: u, channelSpecific: true).getInteger("points", defaultValue: 0);
        x.add([u, point]);
      }
      x.sort((a, b) => b[1].compareTo(a[1]));
      winner = x.first;
      say("Winner: ${winner[0]} (${winner[1]} points)");
      clearMetadata(event);
      return;
    }
    
    q = event.chooseAtRandom(questions);
    
    m++;
  }
  
  var i = questions.indexOf(q);
  event.getChannelMetadata().setInteger("current", i);
  event.getChannelMetadata().incrementInteger("count");
  event.getChannelMetadata().setBoolean("waiting", true);
  say(q.question);
  var answers = new List<String>.from(q.answers)..shuffle();
  
  var right = answers.indexOf(q.answers.first);
  event.getChannelMetadata().setInteger("correct", right);
  
  var x = 0;
  for (var a in answers) {
    say("${letters[x]}. ${answers[x]}");
    x++;
  }
}