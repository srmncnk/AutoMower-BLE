import "dart:async";

import "package:redis/redis.dart";

import "../utils/redis_utils.dart";
import "../utils/time_utils.dart";

class RedisRepository {
  RedisRepository(this.redis);

  final Command redis;
  static const _commandKey = "huski:command";
  static const _messageKey = "huski:last_handled_message";

  Future<String?> loadCommand() async {
    final command = await redis.get(_commandKey) as String?;
    return command;
  }

  Future<void> saveCommand(String command) async {
    await redis.setWithTTL(_commandKey, command, 2.minutes);
  }

  Future<void> deleteCommand() async {
    await redis.delete(_commandKey);
  }

  Future<String?> loadLastHandledMessage() async {
    final message = await redis.get(_messageKey) as String?;
    return message;
  }

  Future<void> saveLastHandledMessage(String message) async {
    await redis.set(_messageKey, message);
  }
}
