import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;
import '../models/attendance_log.dart';

class ExportService {
  static Future<void> exportLogsToCsv(List<AttendanceLog> logs) async {
    final StringBuffer csvBuffer = StringBuffer();
    // UTF-8 BOM for proper Persian rendering in Excel
    csvBuffer.write('\uFEFF');
    csvBuffer.writeln('نام کارمند,تاریخ (شمسی),ساعت ورود,ساعت خروج,مجموع ساعات کار,توضیحات');

    for (final log in logs) {
      final cleanNote = log.note.replaceAll(',', ' - ');
      csvBuffer.writeln(
        '${log.employeeName},${log.jalaliDateFormatted},${log.checkInTimeFormatted},${log.checkOutTimeFormatted},${log.hoursWorked},$cleanNote',
      );
    }

    final String csvContent = csvBuffer.toString();
    final String fileName = 'attendance_report_${DateTime.now().millisecondsSinceEpoch}.csv';

    if (kIsWeb) {
      final bytes = utf8.encode(csvContent);
      final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvContent, encoding: utf8);
      await Share.shareXFiles([XFile(file.path)], text: 'گزارش ماهانه تردد پرسنل');
    }
  }
}
