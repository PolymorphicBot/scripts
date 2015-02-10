import "dart:math";

import "package:polymorphic_bot/plugin.dart";
export "package:polymorphic_bot/plugin.dart";

@Command("calm-down", description: "Calm Down!")
calmDown() => "http://calmingmanatee.com/img/manatee${new Random().nextInt(30) + 1}.jpg";
