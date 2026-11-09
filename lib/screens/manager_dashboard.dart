import 'dart:async';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/app_user.dart';
import '../models/attendance_log.dart';
import '../services/export_service.dart';
import '../services/firebase_service.dart';
import '../widgets/gold_container.dart';
import 'login_screen.dart';

class ManagerDashboard extends StatefulWidget {
  final AppUser currentUser;
  const ManagerDashboard({super.key, required this.currentUser});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  final FirebaseService _service = FirebaseService();
  StreamSubscription? _alertSub;
  bool _initialLoad = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Real-time listener for instant Manager Notification Banner
    _alertSub = _service.getManagerAlertsStream().listen((snapshot) {
      if (_initialLoad) {
        _initialLoad = false;
        return;
      }
      if (snapshot.docs.isNotEmpty && mounted) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            backgroundColor: LuxuryTheme.charcoal,
            leading: const Icon(Icons.notifications_active, color: LuxuryTheme.brightGold),
            content: Text(
              'اعلان آنی: ${data['employeeName']} اکنون «${data['actionType']}» را ثبت کرد.',
              style: const TextStyle(color: LuxuryTheme.brightGold, fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
                child: const Text('متوجه شدم', style: TextStyle(color: LuxuryTheme.metallicGold)),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _alertSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('داشبورد مدیریت و نظارت زنده'),
        actions: [
          IconButton(
            tooltip: 'خروج',
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
      body: StreamBuilder<List<AttendanceLog>>(
        stream: _service.getAllAttendanceStream(),
        builder: (context, snapshot) {
          final allLogs = snapshot.data ?? [];
          final filteredLogs = allLogs.where((log) {
            return log.employeeName.contains(_searchQuery) ||
                log.jalaliDateFormatted.contains(_searchQuery);
          }).toList();

          final int activeNowCount = allLogs.where((l) => l.checkOut == null).length;
          final double totalCompanyHours =
              filteredLogs.fold(0.0, (sum, item) => sum + item.hoursWorked);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Top KPI Summary Cards
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildKpiCard('افراد حاضر در شیفت', '$activeNowCount نفر', Icons.sensors),
                    _buildKpiCard('کل ترددهای ثبت‌شده', '${filteredLogs.length} مورد', Icons.history),
                    _buildKpiCard(
                      'مجموع ساعات کاری',
                      '${totalCompanyHours.toStringAsFixed(1)} ساعت',
                      Icons.timer_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Search Bar & CSV Export Button
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: const InputDecoration(
                          hintText: 'جستجوی نام کارمند یا تاریخ شمسی (مثال: ۱۴۰۵/۰۸)...',
                          prefixIcon: Icon(Icons.search, color: LuxuryTheme.metallicGold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: filteredLogs.isEmpty
                          ? null
                          : () => ExportService.exportLogsToCsv(filteredLogs),
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('خروجی اکسل (CSV)'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Live Attendance Table
                Expanded(
                  child: GoldContainer(
                    padding: const EdgeInsets.all(16),
                    child: filteredLogs.isEmpty
                        ? const Center(
                            child: Text(
                              'گزارشی یافت نشد.',
                              style: TextStyle(color: LuxuryTheme.textMuted),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredLogs.length,
                            separatorBuilder: (_, __) =>
                                Divider(color: LuxuryTheme.metallicGold.withOpacity(0.2)),
                            itemBuilder: (context, index) {
                              final log = filteredLogs[index];
                              final bool isOnline = log.checkOut == null;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isOnline
                                      ? Colors.green.withOpacity(0.2)
                                      : LuxuryTheme.pitchBlack,
                                  child: Icon(
                                    isOnline ? Icons.circle : Icons.check_circle_outline,
                                    color: isOnline ? Colors.greenAccent : LuxuryTheme.metallicGold,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  '${log.employeeName}  •  ${log.jalaliDateFormatted}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: LuxuryTheme.textWhite,
                                  ),
                                ),
                                subtitle: Text(
                                  log.note.isEmpty ? 'بدون توضیحات' : 'توضیحات: ${log.note}',
                                  style: const TextStyle(color: LuxuryTheme.textMuted, fontSize: 12),
                                ),
                                trailing: Wrap(
                                  spacing: 18,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'ورود: ${log.checkInTimeFormatted}',
                                      style: const TextStyle(color: Colors.greenAccent),
                                    ),
                                    Text(
                                      'خروج: ${log.checkOutTimeFormatted}',
                                      style: TextStyle(
                                        color: isOnline ? Colors.amberAccent : Colors.orangeAccent,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: LuxuryTheme.metallicGold),
                                      ),
                                      child: Text(
                                        '${log.hoursWorked} ساعت',
                                        style: const TextStyle(
                                          color: LuxuryTheme.brightGold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon) {
    return SizedBox(
      width: 260,
      child: GoldContainer(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, size: 36, color: LuxuryTheme.brightGold),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: LuxuryTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: LuxuryTheme.brightGold,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
