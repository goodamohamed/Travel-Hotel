import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart' as ap;
import '../../shared/auth_scaffold.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool obscure = true;
  bool submitting = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void _showSnack(
    String message, {
    Color? color,
    IconData icon = Icons.info_outline,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: color ?? const Color(0xFF003B95),
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          duration: duration,
        ),
      );
  }

  Future<void> _signUp() async {
    if (submitting) return;
    final valid = formKey.currentState?.validate() ?? false;
    if (!valid) {
      _showSnack(
        'رجاءً اكمل جميع البيانات بشكل صحيح',
        color: Colors.red.shade600,
        icon: Icons.error_outline,
      );
      return;
    }

    setState(() => submitting = true);
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    _showSnack(
      'جاري إنشاء الحساب...',
      color: const Color(0xFF003B95),
      icon: Icons.person_add_alt_1,
      duration: const Duration(seconds: 2),
    );

    try {
      final ok = await context.read<ap.AuthProvider>().signUp(
            name: name,
            email: email,
            password: pass,
          );

      if (!mounted) return;
      if (ok) {
        _showSnack(
          'تم إنشاء الحساب بنجاح',
          color: Colors.green.shade600,
          icon: Icons.check_circle_outline,
        );

        // AppRouter will automatically go to MainNavigation once authenticated.
        Navigator.pop(context);
      } else {
        final msg = context.read<ap.AuthProvider>().errorMessage ?? 'تعذر إنشاء الحساب';
        _showSnack(msg, color: Colors.red.shade600, icon: Icons.error_outline);
      }
    } on fb.FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'هذا البريد مستخدم بالفعل';
          break;
        case 'invalid-email':
          msg = 'البريد الإلكتروني غير صالح';
          break;
        case 'weak-password':
          msg = 'كلمة المرور ضعيفة، اختر كلمة أقوى';
          break;
        case 'network-request-failed':
          msg = 'خطأ اتصال بالشبكة';
          break;
        case 'operation-not-allowed':
          msg = 'إنشاء حساب بالبريد غير مفعّل في Firebase Console';
          break;
        default:
          msg = 'حدث خطأ أثناء إنشاء الحساب (${e.code})';
      }
      if (mounted) {
        _showSnack(msg, color: Colors.red.shade600, icon: Icons.error_outline);
      }
    } catch (e) {
      if (mounted) {
        _showSnack(
          'تعذر إنشاء الحساب: ${e.toString()}',
          color: Colors.red.shade600,
          icon: Icons.error_outline,
        );
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Register',
      child: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              validator: (v) =>
                  v == null || v.isEmpty || !v.contains('@') ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: passCtrl,
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => obscure = !obscure),
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                ),
              ),
              validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _signUp,
                child: const Text('Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

