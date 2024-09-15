import "package:redis/redis.dart";

import "time_utils.dart";

extension RedisSetterOnRedisCommand on Command {
  Future<void> setWithExpiration(String key, String value, DateTime expiration) async {
    final timeToLive = expiration - DateTime.now();
    return setWithTTL(key, value, timeToLive);
  }

  Future<void> setWithTTL(String key, String value, Duration timeToLive) async {
    await send_object(["SET", key, value]);
    await send_object(['EXPIRE', key, timeToLive.inSeconds]);
  }

  Future<void> delete(String key) async {
    await send_object(["DEL", key]);
  }
}
