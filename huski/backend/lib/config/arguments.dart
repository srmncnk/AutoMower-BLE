import "dart:convert";
import "dart:io";

import "package:args/args.dart";

class ApplicationArguments {
  ApplicationArguments.fromArgs(ArgResults args)
      : configFile = File(args["config"] as String? ?? "config/config.yml");

  final File configFile;

  static ApplicationArguments readFromArgs(List<String> args) {
    final parser = ArgParser()
      ..addOption("config", abbr: "c", defaultsTo: "config/config.yml")
      ..addOption("mode", abbr: "m", defaultsTo: "serve");
    final arguments = parser.parse(args);
    return ApplicationArguments.fromArgs(arguments);
  }

  Map<String, dynamic> toJson() => {
        "config": configFile.path,
      };

  @override
  String toString() => JsonEncoder.withIndent("  ").convert(toJson());
}