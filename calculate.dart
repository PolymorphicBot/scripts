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
calc(input) {
  try {
    Expression exp = parser.parse(input);

    var answer = exp.evaluate(EvaluationType.REAL, context);
    context.bindVariableName("ans", new Number(answer));

    return "[${Color.BLUE}Calculator${Color.RESET}] ${answer}";
  } catch (e) {
    return "[${Color.BLUE}Calculator${Color.RESET}] ERROR: ${e}";
  }
}
