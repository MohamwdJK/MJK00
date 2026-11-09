import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:intl/intl.dart';

class AttendanceLog {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String note;
  final String dateKey; // YYYY-MM-DD for grouping

  AttendanceLog({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    this.checkIn,
    this.checkOut,
    this.note = '',
    required this.dateKey,
  });

  factory AttendanceLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceLog(
      id: doc.id,
      employeeId: data['employeeId'] ?? '',
      employeeName: data['employeeName'] ?? '',
      checkIn: (data['checkIn'] as Timestamp?)?.toDate(),
      checkOut: (data['checkOut'] as Timestamp?)?.toDate(),
      note: data['note'] ?? '',
      dateKey: data['dateKey'] ?? '',
    );
  }

  double get hoursWorked {
    if (checkIn == null || checkOut == null) return 0.0;
    final diff = checkOut!.difference(checkIn!).inMinutes;
    return +(diff / 60.0).toStringAsFixed(2);
  }

  String get jalaliDateFormatted {
    final dt = checkIn ?? DateTime.now();
    final j = Jalali.fromDateTime(dt);
    return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
  }

  String get checkInTimeFormatted =>
      checkIn != null ? DateFormat('HH:mm:ss').format(checkIn!) : '--:--';

  String get checkOutTimeFormatted =>
      checkOut != null ? DateFormat('HH:mm:ss').format(checkOut!) : 'در حال کار...';
}
