import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/firebase_service.dart';
import '../widgets/app_icon_widget.dart';
import '../widgets/gold_container.dart';
import 'employee_dashboard.dart';
import 'manager_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseService = FirebaseService();

  String _selectedRole = 'employee';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً ایمیل و رمز عبور را وارد کنید.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _firebaseService.signInOrRegister(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim().isEmpty ? 'کارمند نمونه' : _nameController.text.trim(),
        role: _selectedRole,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => user.role == 'manager'
              ? ManagerDashboard(currentUser: user)
              : EmployeeDashboard(currentUser: user),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ورود: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: GoldContainer(
              glowing: true,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LuxurySquircleIcon(size: 100),
                  const SizedBox(height: 20),
                  ShaderMask(
                    shaderCallback: (bounds) => LuxuryTheme.goldGradient.createShader(bounds),
                    child: const Text(
                      'سامانه حضور و غیاب اورئوس',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'پرتال هوشمند ثبت تردد پرسنل و مدیران',
                    style: TextStyle(color: LuxuryTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'نام و نام خانوادگی (جهت ثبت‌نام اولیه)',
                      prefixIcon: Icon(Icons.badge_outlined, color: LuxuryTheme.metallicGold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'پست الکترونیک',
                      prefixIcon: Icon(Icons.alternate_email, color: LuxuryTheme.metallicGold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'رمز عبور',
                      prefixIcon: Icon(Icons.lock_outline, color: LuxuryTheme.metallicGold),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'employee',
                          groupValue: _selectedRole,
                          activeColor: LuxuryTheme.brightGold,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('پنل کارمند', style: TextStyle(fontSize: 14)),
                          onChanged: (v) => setState(() => _selectedRole = v!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'manager',
                          groupValue: _selectedRole,
                          activeColor: LuxuryTheme.brightGold,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('پنل مدیر', style: TextStyle(fontSize: 14)),
                          onChanged: (v) => setState(() => _selectedRole = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Icon(Icons.login_rounded),
                      label: Text(_isLoading ? 'در حال اتصال...' : 'ورود به سامانه'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
