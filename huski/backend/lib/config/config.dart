import "dart:io";

import "package:huski_common/huski_common.dart";
import "package:yaml/yaml.dart";
import "package:yaml_writer/yaml_writer.dart";

class ApplicationConfig with Serializable {
  ApplicationConfig.fromYaml(YamlMap yaml)
      : server = _ApplicationServerConfig.fromYaml(yaml["server"]),
        postgres = _ApplicationPostgresConfig.fromYaml(yaml["postgres"]),
        redis = _ApplicationRedisConfig.fromYaml(yaml["redis"]),
        email = _ApplicationEmailConfig.fromYaml(yaml["email"]);

  static ApplicationConfig fromFile(File file) {
    final yaml = loadYaml(file.readAsStringSync());
    return ApplicationConfig.fromYaml(yaml);
  }

  @override
  Json toJson() => {
        "server": server.toJson(),
        "postgres": postgres.toJson(),
        "redis": redis.toJson(),
        "email": email.toJson(),
      };

  final _ApplicationServerConfig server;
  final _ApplicationPostgresConfig postgres;
  final _ApplicationRedisConfig redis;
  final _ApplicationEmailConfig email;

  @override
  String toString() => YamlWriter().write(toJson());
}

class _ApplicationServerConfig with Serializable {
  _ApplicationServerConfig.fromYaml(YamlMap? yaml)
      : address = yaml?["address"] as String? ?? "0.0.0.0",
        port = int.tryParse(yaml?["port"] as String? ?? "") ?? 8083;

  @override
  Json toJson() => {"address": address, "port": port};

  final String address;
  final int port;
}

class _ApplicationPostgresConfig with Serializable {
  _ApplicationPostgresConfig.fromYaml(YamlMap? yaml)
      : address = yaml?["address"] as String? ?? "localhost",
        port = int.tryParse(yaml?["port"] as String? ?? "") ?? 5432,
        database = yaml?["database"] as String? ?? "huski",
        username = yaml?["username"] as String? ?? "postgres",
        password = yaml?["password"] as String? ?? "postgres";

  @override
  Json toJson() => {
        "address": address,
        "port": port,
        "database": database,
        "username": username,
        "password": password,
      };

  final String address;
  final int port;
  final String database;
  final String username;
  final String password;
}

class _ApplicationRedisConfig with Serializable {
  _ApplicationRedisConfig.fromYaml(YamlMap? yaml)
      : address = yaml?["address"] as String? ?? "localhost",
        port = int.tryParse(yaml?["port"] as String? ?? "") ?? 6379;

  @override
  Json toJson() => {
        "address": address,
        "port": port,
      };

  final String address;
  final int port;
}

class _ApplicationEmailConfig with Serializable {
  _ApplicationEmailConfig.fromYaml(YamlMap? yaml)
      : address = yaml?["address"] as String? ?? "smtp-relay.brevo.com",
        port = int.tryParse(yaml?["port"] as String? ?? "") ?? 587,
        username = yaml?["username"] as String,
        password = yaml?["password"] as String,
        from = yaml?["from"] as String? ?? "fittipaldeux@gmail.com",
        fromName = yaml?["from_name"] as String? ?? "Find My Huski",
        to = (yaml?["to"] as YamlList?)?.map((item) => item as String).toList() ?? ["simonescu@gmail.com"];

  @override
  Json toJson() => {
        "address": address,
        "port": port,
        "username": username,
        "password": password,
        "from": from,
        "from_name": fromName,
        "to": to,
      };

  final String address;
  final int port;
  final String username;
  final String password;
  final String from;
  final String fromName;
  final List<String> to;
}
