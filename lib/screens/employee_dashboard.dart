import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../config/theme.dart';
import '../models/app_user.dart';
import '../models/attendance_log.dart';
import '../services/firebase_service.dart';
import '../widgets/gold_container.dart';
import 'login_screen.dart';

class EmployeeDashboard extends StatefulWidget {
  final AppUser currentUser;
  const EmployeeDashboard({super.key, required this.currentUser});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final FirebaseService _service = FirebaseService();
  final TextEditingController _noteController = TextEditingController();
  late Timer _clockTimer;
  DateTime _now = DateTime.now();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _noteController.dispose();
    super.dispose();
  }

  String get _jalaliToday {
    final j = Jalali.fromDateTime(_now);
    return '${j.formatter.wN}، ${j.day} ${j.formatter.mN} ${j.year}';
  }

  Future<void> _handleAction(AttendanceLog? activeSession) async {
    setState(() => _submitting = true);
    try {
      if (activeSession == null) {
        await _service.checkIn(
          user: widget.currentUser,
          note: _noteController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ورود شما با زمان دقیق سرور ثبت و به مدیر اطلاع داده شد.')),
          );
        }
      } else {
        await _service.checkOut(
          logId: activeSession.id,
          user: widget.currentUser,
          note: _noteController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خروج شما با موفقیت ثبت و به مدیر اطلاع داده شد.')),
          );
        }
      }
      _noteController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ثبت تردد: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 860;

    return Scaffold(
      appBar: AppBar(
        title: Text('پنل کارمند | ${widget.currentUser.name}'),
        actions: [
          IconButton(
            tooltip: 'خروج از حساب',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await _service.signOut();
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<AttendanceLog?>(
        stream: _service.getActiveSessionStream(widget.currentUser.uid),
        builder: (context, activeSnap) {
          final activeSession = activeSnap.data;
          final bool isCheckedIn = activeSession != null;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: _buildActionPortal(isCheckedIn, activeSession)),
                      const SizedBox(width: 24),
                      Expanded(flex: 7, child: _buildMonthlyHistory()),
                    ],
                  )
                : ListView(
                    children: [
                      _buildActionPortal(isCheckedIn, activeSession),
                      const SizedBox(height: 24),
                      SizedBox(height: 500, child: _buildMonthlyHistory()),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildActionPortal(bool isCheckedIn, AttendanceLog? activeSession) {
    return GoldContainer(
      glowing: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _jalaliToday,
            style: const TextStyle(color: LuxuryTheme.metallicGold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('HH:mm:ss').format(_now),
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: LuxuryTheme.brightGold,
            ),
          ),
          const SizedBox(height: 24),
          // Prominent Circular Metallic Gold Check-In / Check-Out Button
          GestureDetector(
            onTap: _submitting ? null : () => _handleAction(activeSession),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: 195,
              height: 195,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isCheckedIn
                    ? const LinearGradient(
                        colors: [Color(0xFF4A1212), Color(0xFF1F0707)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LuxuryTheme.goldGradient,
                border: Border.all(
                  color: LuxuryTheme.brightGold,
                  width: isCheckedIn ? 3 : 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isCheckedIn ? Colors.redAccent : LuxuryTheme.brightGold)
                        .withOpacity(0.35),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: _submitting
                    ? const CircularProgressIndicator(color: LuxuryTheme.brightGold)
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCheckedIn ? Icons.logout_rounded : Icons.fingerprint_rounded,
                            size: 58,
                            color: isCheckedIn ? LuxuryTheme.brightGold : LuxuryTheme.pitchBlack,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isCheckedIn ? 'ثبت خروج' : 'ثبت ورود',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isCheckedIn ? LuxuryTheme.brightGold : LuxuryTheme.pitchBlack,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (isCheckedIn && activeSession?.checkIn != null)
            Text(
              'ساعت ورود امروز: ${activeSession!.checkInTimeFormatted}',
              style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 18),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'توضیحات یا وضعیت (اختیاری - مثال: ماموریت / دورکاری)',
              prefixIcon: Icon(Icons.edit_note_rounded, color: LuxuryTheme.metallicGold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyHistory() {
    return StreamBuilder<List<AttendanceLog>>(
      stream: _service.getEmployeeHistoryStream(widget.currentUser.uid),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        final double totalMonthHours = logs.fold(0.0, (sum, item) => sum + item.hoursWorked);

        return GoldContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'سوابق تردد ماهانه',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: LuxuryTheme.brightGold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: LuxuryTheme.pitchBlack,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LuxuryTheme.metallicGold),
                    ),
                    child: Text(
                      'مجموع ساعات: ${totalMonthHours.toStringAsFixed(1)} ساعت',
                      style: const TextStyle(
                        color: LuxuryTheme.brightGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: LuxuryTheme.metallicGold, height: 28),
              Expanded(
                child: logs.isEmpty
                    ? const Center(
                        child: Text(
                          'هنوز ترددی ثبت نشده است.',
                          style: TextStyle(color: LuxuryTheme.textMuted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: logs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: LuxuryTheme.pitchBlack,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: LuxuryTheme.metallicGold.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.jalaliDateFormatted,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: LuxuryTheme.brightGold,
                                      ),
                                    ),
                                    if (log.note.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'یادداشت: ${log.note}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: LuxuryTheme.textMuted,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _timeBadge('ورود', log.checkInTimeFormatted, Colors.greenAccent),
                                    const SizedBox(width: 12),
                                    _timeBadge('خروج', log.checkOutTimeFormatted, Colors.orangeAccent),
                                    const SizedBox(width: 12),
                                    _timeBadge('ساعت', '${log.hoursWorked}', LuxuryTheme.brightGold),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _timeBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: LuxuryTheme.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
