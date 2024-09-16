import 'package:huski_common/huski_common.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

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

  Future<void> notify(MowerState state) async {
    final smtpServer = SmtpServer(
      address,
      port: port,
      username: username,
      password: password,
      ssl: false,
      allowInsecure: true,
    );

    final timeFormat = DateFormat("HH:mm, dd.MM.yy");
    final lastMessage = state.lastMessage != null ? state.lastMessage!.toString().replaceAll("ErrorCodes.", "") : "---";
    final lastMessageTime = state.lastMessageTime != null //
        ? timeFormat.format(DateTime.fromMillisecondsSinceEpoch(state.lastMessageTime! * 1000, isUtc: true))
        : null;

    final message = Message()
      ..from = Address(from, fromName)
      ..recipients.addAll(to)
      ..subject = "Huski has just sent you a new message"
      ..text = "The new message is called '$lastMessage'. It was recorded at $lastMessageTime.\n\nKind regards,\nHuski";

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
