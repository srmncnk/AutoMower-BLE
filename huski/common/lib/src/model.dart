
import 'json_utils.dart';

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
        createdAt = json["created_at"] as DateTime?;

  Json toJson() => {
        "name": name,
        "model": model,
        "serial_number": serialNumber,
        "manufacturer": manufacturer,
        "state": state != null ? state!.index : null,
        "activity": activity != null ? activity!.index : null,
        "last_message": lastMessage != null ? lastMessage!.code : null,
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
