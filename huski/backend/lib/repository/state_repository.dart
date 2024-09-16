import "dart:async";
import "dart:math";

import "package:collection/collection.dart";
import "package:huski_common/huski_common.dart";
import "package:postgres/postgres.dart";

class StateRepository {
  StateRepository(this.database);

  final PostgreSQLConnection database;
  static const _fields = "state, activity, last_message, last_message_time, next_start_time, battery_level, is_charging, "
      "total_running_time, total_cutting_time, total_charging_time, total_searching_time, number_of_collisions, "
      "number_of_charging_cycles, blade_usage_time, created_at";

  Future<List<MowerState>> list(int page, int limit, bool distinct) async {
    if (distinct) {
      return listDistinct(page, limit);
    }
    final result = await database.query(
      "SELECT $_fields "
      "FROM state "
      "ORDER BY created_at DESC "
      "LIMIT @limit OFFSET @offset ",
      substitutionValues: {
        "limit": limit,
        "offset": page * limit,
      },
    );
    final rows = result.map((row) => row.toColumnMap());
    return rows.map(MowerState.fromJson).toList();
  }

  Future<List<MowerState>> listDistinct(int page, int limit) async {
    const maxLimit = 1 << 16;
    final states = await list(0, maxLimit, false);
    for (var index = 1; index < states.length; index++) {
      final state = states[index], previousState = states[index - 1];
      if (state.activity == previousState.activity && state.state == previousState.state) {
        states.removeAt(index--);
      }
    }
    final startIndex = min(page * limit, states.length), endIndex = min((page + 1) * limit, states.length);
    return states.sublist(startIndex, endIndex);
  }

  Future<MowerState?> save(MowerState state) async {
    final result = await database.query(
      "INSERT INTO state "
      "($_fields) "
      "VALUES (@state, @activity, @lastMessage, @lastMessageTime, @nextStartTime, @batteryLevel, @isCharging, "
      "@totalRunningTime, @totalCuttingTime, @totalChargingTime, @totalSearchingTime, "
      "@numberOfCollisions, @numberOfChargingCycles, @bladeUsageTime, @createdAt) "
      "RETURNING $_fields",
      substitutionValues: {
        "state": state.state?.index,
        "activity": state.activity?.index,
        "lastMessage": state.lastMessage?.index,
        "lastMessageTime": state.lastMessageTime,
        "nextStartTime": state.nextStartTime,
        "batteryLevel": state.batteryLevel,
        "isCharging": state.isCharging,
        "totalRunningTime": state.totalRunningTime,
        "totalCuttingTime": state.totalCuttingTime,
        "totalChargingTime": state.totalChargingTime,
        "totalSearchingTime": state.totalSearchingTime,
        "numberOfCollisions": state.numberOfCollisions,
        "numberOfChargingCycles": state.numberOfChargingCycles,
        "bladeUsageTime": state.bladeUsageTime,
        "createdAt": DateTime.now(),
      },
    );
    final row = result.firstOrNull?.toColumnMap();
    return row != null ? MowerState.fromJson(row) : null;
  }

  Future<void> deleteWhereOlderThan(DateTime dateTime) async {
    await database.query(
      "DELETE FROM state "
      "WHERE created_at < @dateTime ",
      substitutionValues: {"dateTime": dateTime},
    );
  }
}