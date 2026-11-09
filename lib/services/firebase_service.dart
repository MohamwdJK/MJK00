import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/app_user.dart';
import '../models/attendance_log.dart';
import 'notification_service.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign In or Auto-Register for quick deployment testing
  Future<AppUser> signInOrRegister({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    UserCredential cred;
    try {
      cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        await _db.collection('users').doc(cred.user!.uid).set({
          'name': name,
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        rethrow;
      }
    }

    final doc = await _db.collection('users').doc(cred.user!.uid).get();
    if (!doc.exists) {
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
      });
      return AppUser(uid: cred.user!.uid, name: name, email: email, role: role);
    }
    return AppUser.fromMap(doc.id, doc.data()!);
  }

  Future<void> signOut() => _auth.signOut();

  // Check if user currently has an open session (Checked-in but not Checked-out)
  Stream<AttendanceLog?> getActiveSessionStream(String employeeId) {
    return _db
        .collection('attendance')
        .where('employeeId', isEqualTo: employeeId)
        .where('checkOut', isNull: true)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : AttendanceLog.fromFirestore(snap.docs.first));
  }

  // Record Check-In with Server Timestamp
  Future<void> checkIn({
    required AppUser user,
    required String note,
  }) async {
    final String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _db.collection('attendance').add({
      'employeeId': user.uid,
      'employeeName': user.name,
      'checkIn': FieldValue.serverTimestamp(),
      'checkOut': null,
      'note': note,
      'dateKey': todayKey,
    });

    await NotificationService.notifyManager(
      employeeName: user.name,
      actionType: 'ثبت ورود (Check-In)',
      note: note,
    );
  }

  // Record Check-Out with Server Timestamp
  Future<void> checkOut({
    required String logId,
    required AppUser user,
    required String note,
  }) async {
    final docRef = _db.collection('attendance').doc(logId);
    final existing = await docRef.get();
    final String previousNote = (existing.data()?['note'] ?? '').toString();
    final String combinedNote = note.isEmpty
        ? previousNote
        : (previousNote.isEmpty ? note : '$previousNote | خروج: $note');

    await docRef.update({
      'checkOut': FieldValue.serverTimestamp(),
      'note': combinedNote,
    });

    await NotificationService.notifyManager(
      employeeName: user.name,
      actionType: 'ثبت خروج (Check-Out)',
      note: note,
    );
  }

  // Employee Monthly History Stream
  Stream<List<AttendanceLog>> getEmployeeHistoryStream(String employeeId) {
    return _db
        .collection('attendance')
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('checkIn', descending: true)
        .limit(60)
        .snapshots()
        .map((snap) => snap.docs.map(AttendanceLog.fromFirestore).toList());
  }

  // All Logs Stream for Manager View
  Stream<List<AttendanceLog>> getAllAttendanceStream() {
    return _db
        .collection('attendance')
        .orderBy('checkIn', descending: true)
        .limit(200)
        .snapshots()
        .map((snap) => snap.docs.map(AttendanceLog.fromFirestore).toList());
  }

  // Live Manager Alert Stream
  Stream<QuerySnapshot> getManagerAlertsStream() {
    return _db
        .collection('manager_alerts')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();
  }
}
