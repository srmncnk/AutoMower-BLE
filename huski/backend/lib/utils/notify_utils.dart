import 'dart:convert';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../repository/state_repository.dart';
import 'logger_utils.dart';

class Notifier {
  Notifier(this.address, this.port, this.username, this.password, this.from, this.fromName, this.to);

  final String address;
  final int port;
  final String username;
  final String password;
  final String from;
  final String fromName;
  final List<String> to;
  final ServiceLogger log = ServiceLogger("Notifier");

  Future<void> notify(State state) async {
    final smtpServer = SmtpServer(
      address,
      port: port,
      username: username,
      password: password,
      ssl: false,
      allowInsecure: true,
    );

    final message = Message()
      ..from = Address(from, fromName)
      ..recipients.addAll(to)
      ..subject = "New message from Huski"
      ..text = jsonEncode({
        ...state.toJson(),
        if (state.state != null) "readable_state": state.toString(),
        if (state.activity != null) "readable_activity": state.activity!.toString(),
        if (state.lastMessage != null) "readable_last_message": state.lastMessage!.toString(),
        if (state.lastMessageTime != null) "readable_last_message_time": DateTime.fromMillisecondsSinceEpoch(state.lastMessageTime!).toIso8601String(),
        if (state.nextStartTime != null) "readable_next_start_time": DateTime.fromMillisecondsSinceEpoch(state.nextStartTime!).toIso8601String(),
      });

    try {
      final sendReport = await send(message, smtpServer);
      log.log(messages: {
        "message": message.text,
        "sent_at": sendReport.messageSendingEnd.toIso8601String(),
      });
    } on MailerException catch (e) {
      log.log(messages: {"error": e.message});
    }
  }
}
