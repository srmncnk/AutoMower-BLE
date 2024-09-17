import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:huski_common/huski_common.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";
import "package:intl/intl.dart";

import "../api/api.dart";

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  static const _pageSize = 10;
  late bool _distinct;
  late bool _ping;
  final PagingController<int, MowerState> _pagingController = PagingController(firstPageKey: 0);

  @override
  void initState() {
    _distinct = true;
    _ping = false;
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final list = await HuskiApi.getState(pageKey, _pageSize, _distinct);
      final isLastPage = list.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(list);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(list, nextPageKey);
      }
      _ping = await HuskiApi.getPing();
      setState(() {});
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Text("Reports", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(" •", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _ping ? Colors.green : Colors.transparent)),
            ]),
            Row(
              children: [
                const Text("Distinct", style: TextStyle(fontSize: 14)),
                Checkbox(
                  value: _distinct,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _distinct = value;
                        _pagingController.refresh();
                      });
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _pagingController.refresh(),
        child: PagedListView<int, MowerState>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<MowerState>(
            itemBuilder: (context, rawItem, index) {
              final item = ReadableMowerState.fromMowerState(rawItem);
              return Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  title: Container(
                    decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${item.niceState} (${item.activity})"),
                            Text(item.seenAgo, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                          ],
                        ),
                        FaIcon(_getIcon(rawItem), color: _getIconColor(rawItem), size: 12),
                      ],
                    ),
                  ),
                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("State: ${item.state}", style: const TextStyle(fontSize: 14)),
                          Text("Activity: ${item.activity}", style: const TextStyle(fontSize: 14)),
                          Text("Last Message: ${item.lastMessage}", style: const TextStyle(fontSize: 14)),
                          if (item.lastMessageTime != null)
                            Text("Reported: ${item.lastMessageTime!}", style: const TextStyle(fontSize: 14)),
                          Text("Next Start: ${item.nextStartTime}", style: const TextStyle(fontSize: 14)),
                          Text("Battery Level: ${item.batteryLevel}", style: const TextStyle(fontSize: 14)),
                          Text("Is Charging: ${item.isCharging}", style: const TextStyle(fontSize: 14)),
                          Text("Updated at: ${item.createdAt}", style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  IconData _getIcon(MowerState mowerState) {
    final icon = switch (mowerState.activity) {
      MowerActivity.charging => FontAwesomeIcons.chargingStation,
      MowerActivity.goingHome => FontAwesomeIcons.house,
      MowerActivity.goingOut => FontAwesomeIcons.doorOpen,
      MowerActivity.mowing => FontAwesomeIcons.seedling,
      MowerActivity.none => FontAwesomeIcons.question,
      MowerActivity.parked => FontAwesomeIcons.house,
      MowerActivity.stoppedInGarden => FontAwesomeIcons.exclamation,
      null => FontAwesomeIcons.exclamation,
    };
    return icon;
  }

  Color _getIconColor(MowerState mowerState) {
    final color = switch (mowerState.state) {
      MowerStateEnum.error => Colors.orange,
      MowerStateEnum.fatalError => Colors.orange,
      MowerStateEnum.inOperation => Colors.teal.shade200,
      MowerStateEnum.off => Colors.grey,
      MowerStateEnum.paused => Colors.white,
      MowerStateEnum.pendingStart => Colors.white,
      MowerStateEnum.restricted => Colors.grey,
      MowerStateEnum.stopped => Colors.white,
      MowerStateEnum.waitForSafetyPin => Colors.orange,
      null => Colors.orange, // Handle null case
    };
    return color;
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
    final timeFormat = DateFormat("HH:mm, dd.MM.yy");
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
      null => "---",
    };
    final state = mowerState.state?.toString().replaceAll("MowerStateEnum.", "") ?? "---";
    final activity = mowerState.activity?.toString().replaceAll("MowerActivity.", "") ?? "---";
    final lastMessage = mowerState.lastMessage != null ? mowerState.lastMessage!.toString().replaceAll("ErrorCodes.", "") : "---";
    final lastMessageTime = mowerState.lastMessageTime != null //
        ? timeFormat.format(DateTime.fromMillisecondsSinceEpoch(mowerState.lastMessageTime! * 1000, isUtc: true))
        : null;
    final nextStartTime = mowerState.nextStartTime != null && mowerState.nextStartTime != 0
        ? timeFormat.format(DateTime.fromMillisecondsSinceEpoch(mowerState.nextStartTime! * 1000, isUtc: true))
        : "---";
    final batteryLevel = "${mowerState.batteryLevel ?? "---"}%";
    final isCharging = mowerState.isCharging == true ? "yes" : "no";
    final createdAt = mowerState.createdAt!.toString();
    final Duration difference = DateTime.now().toUtc().difference(mowerState.createdAt!);
    String seenAgo;
    if (difference.inMinutes < 60) {
      int minutes = difference.inMinutes;
      seenAgo = "$minutes minute${minutes == 1 ? '' : 's'} ago";
    } else if (difference.inHours < 24) {
      int hours = difference.inHours;
      seenAgo = "$hours hour${hours == 1 ? '' : 's'} ago";
    } else {
      int days = difference.inDays;
      seenAgo = "$days day${days == 1 ? '' : 's'} ago";
    }
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
