import "package:flutter/material.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";
import "package:http/http.dart" as http;
import "dart:convert";

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  static const _pageSize = 10;
  final PagingController<int, MowerState> _pagingController = PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final response = await http.get(Uri.parse("https://api.irmancnik.dev/huski/v1/state?page=$pageKey&limit=$_pageSize"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> jsonList = json["list"];
        final List<MowerState> newItems = jsonList.map((json) => MowerState.fromJson(json)).toList();

        final isLastPage = newItems.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(newItems, nextPageKey);
        }
      } else {
        throw Exception("Failed to load statuses");
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _pagingController.refresh(),
        child: PagedListView<int, MowerState>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<MowerState>(
            itemBuilder: (context, rawItem, index) {
              final item = ReadableMowerState.fromMowerState(rawItem);
              return ExpansionTile(
                title: Text("${item.niceState} (${item.activity})"),
                subtitle: Text(item.seenAgo),
                children: [
                  ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("State: ${item.state}"),
                        Text("Activity: ${item.activity}"),
                        Text("Last Message: ${item.lastMessage}"),
                        if (item.lastMessageTime != null) Text("Reported: ${item.lastMessageTime!}"),
                        Text("Next Start Time: ${item.nextStartTime}"),
                        Text("Battery Level: ${item.batteryLevel}%"),
                        Text("Is Charging: ${item.isCharging}"),
                        Text("Updated at: ${item.createdAt}"),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ReadableMowerState {
  ReadableMowerState._(
    this.state,
    this.niceState,
    this.activity,
    this.lastMessage,
    this.lastMessageTime,
    this.nextStartTime,
    this.batteryLevel,
    this.isCharging,
    this.createdAt,
    this.seenAgo,
  );

  static ReadableMowerState fromMowerState(MowerState mowerState) {
    final niceState = switch (mowerState.state) {
      MowerStateEnum.error => "Error",
      MowerStateEnum.fatalError => "Fatal error",
      MowerStateEnum.inOperation => "In operation",
      MowerStateEnum.off => "Off",
      MowerStateEnum.paused => "Paused",
      MowerStateEnum.pendingStart => "Pending start",
      MowerStateEnum.restricted => "Restricted",
      MowerStateEnum.stopped => "Stopped",
      MowerStateEnum.waitForSafetyPin => "Waiting for pin",
      null => "---", // Handle null case
    };
    final state = mowerState.state?.toString().replaceAll("MowerStateEnum.", "") ?? "---";
    final activity = mowerState.activity?.toString().replaceAll("MowerActivity.", "") ?? "---";
    final lastMessage = mowerState.lastMessage != null ? mowerState.lastMessage!.toString().replaceAll("ErrorCodes.", "") : "---";
    final lastMessageTime = mowerState.lastMessageTime != null //
        ? DateTime.fromMillisecondsSinceEpoch(mowerState.lastMessageTime! * 1000).toString()
        : null;
    final nextStartTime = mowerState.nextStartTime != null && mowerState.nextStartTime != 0
        ? DateTime.fromMillisecondsSinceEpoch(mowerState.nextStartTime! * 1000).toString()
        : "---";
    final batteryLevel = "${mowerState.batteryLevel ?? "---"}%";
    final isCharging = mowerState.isCharging == true ? "yes" : "no";
    final createdAt = mowerState.createdAt!.toString();
    final seenAgo = "${(DateTime.now().toUtc() - mowerState.createdAt!).inMinutes} minutes ago";
    return ReadableMowerState._(
        state, niceState, activity, lastMessage, lastMessageTime, nextStartTime, batteryLevel, isCharging, createdAt, seenAgo);
  }

  final String state;
  final String niceState;
  final String activity;
  final String lastMessage;
  final String? lastMessageTime;
  final String nextStartTime;
  final String batteryLevel;
  final String isCharging;
  final String createdAt;
  final String seenAgo;
}

class MowerState with Serializable {
  MowerState.fromJson(Json json)
      : name = json["name"] as String?,
        model = json["model"] as String?,
        serialNumber = json["serial_number"] as int?,
        manufacturer = json["manufacturer"] as String?,
        state = json["state"] is int ? MowerStateEnum.values[json["state"] as int] : null,
        activity = json["activity"] is int ? MowerActivity.values[json["activity"] as int] : null,
        lastMessage = json["last_message"] is int ? ErrorCodesExtension.fromCode(json["last_message"] as int) : null,
        lastMessageTime = json["last_message_time"] as int?,
        nextStartTime = json["next_start_time"] as int?,
        batteryLevel = json["battery_level"] as int?,
        isCharging = json["is_charging"] as bool?,
        totalRunningTime = json["total_running_time"] as int?,
        totalCuttingTime = json["total_cutting_time"] as int?,
        totalChargingTime = json["total_charging_time"] as int?,
        totalSearchingTime = json["total_searching_time"] as int?,
        numberOfCollisions = json["number_of_collisions"] as int?,
        numberOfChargingCycles = json["number_of_charging_cycles"] as int?,
        bladeUsageTime = json["blade_usage_time"] as int?,
        createdAt = DateTime.tryParse(json["created_at"] as String? ?? "");

  @override
  Json toJson() => {
        "name": name,
        "model": model,
        "serial_number": serialNumber,
        "manufacturer": manufacturer,
        "state": state?.index,
        "activity": activity?.index,
        "last_message": lastMessage?.code,
        "last_message_time": lastMessageTime,
        "next_start_time": nextStartTime,
        "battery_level": batteryLevel,
        "is_charging": isCharging,
        "total_running_time": totalRunningTime,
        "total_cutting_time": totalCuttingTime,
        "total_charging_time": totalChargingTime,
        "total_searching_time": totalSearchingTime,
        "number_of_collisions": numberOfCollisions,
        "number_of_charging_cycles": numberOfChargingCycles,
        "blade_usage_time": bladeUsageTime,
        "created_at": createdAt?.toIso8601String(),
      }..removeWhere((_, value) => value == null);

  final String? name;
  final String? model;
  final int? serialNumber;
  final String? manufacturer;
  final MowerStateEnum? state;
  final MowerActivity? activity;
  final ErrorCodes? lastMessage;
  final int? lastMessageTime;
  final int? nextStartTime;
  final int? batteryLevel;
  final bool? isCharging;
  final int? totalRunningTime;
  final int? totalCuttingTime;
  final int? totalChargingTime;
  final int? totalSearchingTime;
  final int? numberOfCollisions;
  final int? numberOfChargingCycles;
  final int? bladeUsageTime;
  final DateTime? createdAt;
}

enum MowerStateEnum { off, waitForSafetyPin, stopped, fatalError, pendingStart, paused, inOperation, restricted, error }

enum MowerActivity { none, charging, goingOut, mowing, goingHome, parked, stoppedInGarden }

enum ErrorCodes {
  unexpectedError,
  outsideWorkingArea,
  noLoopSignal,
  wrongLoopSignal,
  loopSensorProblemFront,
  loopSensorProblemRear,
  loopSensorProblemLeft,
  loopSensorProblemRight,
  wrongPinCode,
  trapped,
  upsideDown,
  lowBattery,
  emptyBattery,
  noDrive,
  mowerLifted,
  lifted,
  stuckInChargingStation,
  chargingStationBlocked,
  collisionSensorProblemRear,
  collisionSensorProblemFront,
  wheelMotorBlockedRight,
  wheelMotorBlockedLeft,
  wheelDriveProblemRight,
  wheelDriveProblemLeft,
  cuttingSystemBlocked,
  cuttingSystemBlocked2,
  invalidSubDeviceCombination,
  settingsRestored,
  memoryCircuitProblem,
  slopeTooSteep,
  chargingSystemProblem,
  stopButtonProblem,
  tiltSensorProblem,
  mowerTilted,
  cuttingStoppedSlopeTooSteep,
  wheelMotorOverloadedRight,
  wheelMotorOverloadedLeft,
  chargingCurrentTooHigh,
  electronicProblem,
  cuttingMotorProblem,
  limitedCuttingHeightRange,
  unexpectedCuttingHeightAdj,
  limitedCuttingHeightRange2,
  cuttingHeightProblemDrive,
  cuttingHeightProblemCurr,
  cuttingHeightProblemDir,
  cuttingHeightBlocked,
  cuttingHeightProblem,
  noResponseFromCharger,
  ultrasonicProblem,
  guide1NotFound,
  guide2NotFound,
  guide3NotFound,
  gpsNavigationProblem,
  weakGpsSignal,
  difficultFindingHome,
  guideCalibrationAccomplished,
  guideCalibrationFailed,
  temporaryBatteryProblem,
  temporaryBatteryProblem2,
  temporaryBatteryProblem3,
  temporaryBatteryProblem4,
  temporaryBatteryProblem5,
  temporaryBatteryProblem6,
  temporaryBatteryProblem7,
  temporaryBatteryProblem8,
  batteryProblem,
  batteryProblem2,
  temporaryBatteryProblem9,
  alarmMowerSwitchedOff,
  alarmMowerStopped,
  alarmMowerLifted,
  alarmMowerTilted,
  alarmMowerInMotion,
  alarmOutsideGeofence,
  connectionChanged,
  connectionNotChanged,
  comBoardNotAvailable,
  slippedMowerHasSlipped,
  invalidBatteryCombination,
  cuttingSystemImbalance,
  safetyFunctionFaulty,
  wheelMotorBlockedRearRight,
  wheelMotorBlockedRearLeft,
  wheelDriveProblemRearRight,
  wheelDriveProblemRearLeft,
  wheelMotorOverloadedRearRight,
  wheelMotorOverloadedRearLeft,
  angularSensorProblem,
  invalidSystemConfiguration,
  noPowerInChargingStation,
  switchCordProblem,
  workAreaNotValid,
  noAccuratePositionFromSatellites,
  referenceStationCommunicationProblem,
  foldingSensorActivated,
  rightBrushMotorOverloaded,
  leftBrushMotorOverloaded,
  ultrasonicSensor1Defect,
  ultrasonicSensor2Defect,
  ultrasonicSensor3Defect,
  ultrasonicSensor4Defect,
  cuttingDriveMotor1Defect,
  cuttingDriveMotor2Defect,
  cuttingDriveMotor3Defect,
  liftSensorDefect,
  collisionSensorDefect,
  dockingSensorDefect,
  foldingCuttingDeckSensorDefect,
  loopSensorDefect,
  collisionSensorError,
  noConfirmedPosition,
  cuttingSystemMajorImbalance,
  complexWorkingArea,
  tooHighDischargeCurrent,
  tooHighInternalCurrent,
  highChargingPowerLoss,
  highInternalPowerLoss,
  chargingSystemProblem2,
  zoneGeneratorProblem,
  internalVoltageError,
  highInternalTemperature,
  canError,
  destinationNotReachable,
  destinationBlocked,
  batteryNeedsReplacement,
  batteryNearEndOfLife,
  batteryProblem3,
  multipleReferenceStationsDetected,
  auxiliaryCuttingMeansBlocked,
  imbalancedAuxiliaryCuttingDiscDetected,
  liftedInLinkArm,
  eposAccessoryMissing,
  bluetoothComWithCsFailed,
  invalidSwConfiguration,
  radarProblem,
  workAreaTampered,
  highTemperatureInCuttingMotorRight,
  highTemperatureInCuttingMotorCenter,
  highTemperatureInCuttingMotorLeft,
  wheelBrushMotorProblem,
  accessoryPowerProblem,
  boundaryWireProblem,
  connectivityProblem,
  connectivitySettingsRestored,
  connectivityProblem2,
  connectivityProblem3,
  connectivityProblem4,
  poorSignalQuality,
  simCardRequiresPin,
  simCardLocked,
  simCardNotFound,
  simCardLocked2,
  simCardLocked3,
  simCardLocked4,
  geofenceProblem,
  geofenceProblem2,
  connectivityProblem5,
  connectivityProblem6,
  smsCouldNotBeSent,
  communicationCircuitBoardSwMustBeUpdated,
}

extension ErrorCodesExtension on ErrorCodes {
  int get code {
    if (this == ErrorCodes.communicationCircuitBoardSwMustBeUpdated) return 724;
    final code = ErrorCodes.values.indexOf(this);
    final border = ErrorCodes.values.indexOf(ErrorCodes.connectivityProblem);
    if (code < border) {
      return code;
    }
    return 701 + code - border;
  }

  // Convert an integer value to its associated enum
  static ErrorCodes? fromCode(int code) {
    if (code == 724) return ErrorCodes.communicationCircuitBoardSwMustBeUpdated;
    final border = ErrorCodes.values.indexOf(ErrorCodes.connectivityProblem);
    if (code < border) {
      return ErrorCodes.values[code];
    }
    return ErrorCodes.values[code + border - 701];
  }
}

typedef Json = Map<String, Object?>;

mixin SerializableTo<T> {
  @mustCallSuper
  T toJson();
}

mixin Serializable implements SerializableTo<Json> {}

extension SerializableJsonList on Iterable<Serializable> {
  List<Json> toJsonList() => map((entry) => entry.toJson()).toList();
}

extension DateTimeUtils on DateTime {
  Duration operator -(DateTime other) => difference(other);
  DateTime operator +(Duration duration) => add(duration);
}

extension IntDurationUtils on int {
  Duration get microseconds => Duration(microseconds: this);
  Duration get milliseconds => Duration(milliseconds: this);
  Duration get seconds => Duration(seconds: this);
  Duration get minutes => Duration(minutes: this);
  Duration get hours => Duration(hours: this);
  Duration get days => Duration(days: this);
  Duration get weeks => Duration(days: this * 7);
  Duration get months => Duration(days: this * 30);
  Duration get years => Duration(days: this * 365);
}
