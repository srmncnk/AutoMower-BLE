import "dart:async";

import "package:postgres/postgres.dart";
import "package:redis/redis.dart";
import "package:shelf/shelf_io.dart" as io;

import "config/arguments.dart";
import "config/config.dart";
import "router/router.dart" as router;

// TODO:
//* ThunderClient setup
//* CREATE TABLE on postgres
//* Mobile client
//* Pushing from findmyhuski
//* Receiving on findmyhuski

void main(List<String> args) async {
  final arguments = ApplicationArguments.readFromArgs(args);
  final config = ApplicationConfig.fromFile(arguments.configFile);
  print("Config: $config");

  final database = await _initDatabase(config);
  final redis = await _initRedis(config);
  final handler = await router.initRoutes(config, database, redis);

  final server = await io.serve(handler, config.server.address, config.server.port);
  print("Serving at ${server.address.host}:${server.port}");
}

Future<PostgreSQLConnection> _initDatabase(ApplicationConfig config) async {
  final database = PostgreSQLConnection(
    config.postgres.address,
    config.postgres.port,
    config.postgres.database,
    username: config.postgres.username,
    password: config.postgres.password,
  );
  await database.open();
  return database;
}

Future<Command> _initRedis(ApplicationConfig config) async {
  final redisConnection = RedisConnection();
  final redis = await redisConnection.connect(config.redis.address, config.redis.port);
  return redis;
}