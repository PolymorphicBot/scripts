import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

import "dart:math" as Math;

import "package:math_expressions/math_expressions.dart";

const dependencies = const {
  "math_expressions": ">=0.1.0 <0.2.0"
};

@PluginInstance()
Plugin plugin;
@BotInstance()
BotConnector bot;

Parser parser = new Parser();
ContextModel context = new ContextModel()
  ..bindVariableName("pi", new Number(Math.PI));

@Command("calc", description: "Calculate Math Expressions", usage: "<expression>")
calc(CommandEvent event) {
  if (event.args.isEmpty) {
    event.reply("> Usage: calc <expression>");
  } else {
    try {
      Expression exp = parser.parse(event.args.join(" "));
      var answer = exp.evaluate(EvaluationType.REAL, context);
      event.reply("${answer}", prefixContent: "Calculate");

      context.bindVariableName("ans", new Number(answer));
    } catch (e) {
      event.reply("ERROR: ${e}", prefixContent: "Calculate");
    }
  }
}
