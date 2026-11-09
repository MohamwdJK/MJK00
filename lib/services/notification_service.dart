import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationService {
  // Replace with your Telegram Bot Token & Manager Chat ID for instant Telegram push alerts
  static const String _telegramBotToken = 'YOUR_TELEGRAM_BOT_TOKEN';
  static const String _managerChatId = 'YOUR_MANAGER_CHAT_ID';

  static Future<void> notifyManager({
    required String employeeName,
    required String actionType, // 'ورود (Check-In)' or 'خروج (Check-Out)'
    required String note,
  }) async {
    final String timeStr = DateFormat('HH:mm:ss').format(DateTime.now());
    final String message = '🔔 *گزارش حضور و غیاب*\n'
        '👤 *کارمند:* $employeeName\n'
        '⚡ *وضعیت:* $actionType\n'
        '🕒 *زمان ثبت:* $timeStr\n'
        '📝 *توضیحات:* ${note.isEmpty ? "ندارد" : note}';

    // 1. Write to Firestore real-time manager_alerts collection (triggers in-app banner for Manager)
    await FirebaseFirestore.instance.collection('manager_alerts').add({
      'employeeName': employeeName,
      'actionType': actionType,
      'note': note,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Dispatch instant webhook to Telegram Bot API
    if (_telegramBotToken != 'YOUR_TELEGRAM_BOT_TOKEN') {
      try {
        final uri = Uri.parse('https://api.telegram.org/bot$_telegramBotToken/sendMessage');
        await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'chat_id': _managerChatId,
            'text': message,
            'parse_mode': 'Markdown',
          }),
        );
      } catch (_) {
        // Fail silently if offline or token unconfigured
      }
    }
  }
}
