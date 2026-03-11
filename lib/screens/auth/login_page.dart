import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart' as ap;
import '../../shared/auth_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool obscure = true;

  @override
  void dispose() {
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

  Future<void> _signIn() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;
    final valid = formKey.currentState?.validate() ?? false;
    if (!valid) {
      if (email.isEmpty || !email.contains('@')) {
        _showSnack(
          'من فضلك أدخل بريد إلكتروني صالح',
          color: Colors.red.shade600,
          icon: Icons.error_outline,
        );
      } else if (pass.length < 6) {
        _showSnack(
          'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
          color: Colors.red.shade600,
          icon: Icons.error_outline,
        );
      } else {
        _showSnack(
          'رجاءً صحّح الحقول المظللة',
          color: Colors.red.shade600,
          icon: Icons.error_outline,
        );
      }
      return;
    }

    _showSnack(
      'جاري تسجيل الدخول...',
      color: const Color(0xFF003B95),
      icon: Icons.login,
      duration: const Duration(seconds: 2),
    );

    try {
      final ok = await context.read<ap.AuthProvider>().signIn(
            email: email,
            password: pass,
          );

      if (!mounted) return;
      if (ok) {
        _showSnack(
          'تم تسجيل الدخول بنجاح',
          color: Colors.green.shade600,
          icon: Icons.check_circle_outline,
        );
        Navigator.pop(context);
      } else {
        final msg = context.read<ap.AuthProvider>().errorMessage ?? 'تعذر تسجيل الدخول';
        _showSnack(msg, color: Colors.red.shade600, icon: Icons.error_outline);
      }
    } on fb.FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = 'لا يوجد حساب بهذا البريد';
          break;
        case 'wrong-password':
          msg = 'كلمة المرور غير صحيحة';
          break;
        case 'invalid-email':
          msg = 'البريد الإلكتروني غير صالح';
          break;
        case 'too-many-requests':
          msg = 'محاولات كثيرة، حاول لاحقًا';
          break;
        case 'network-request-failed':
          msg = 'خطأ اتصال بالشبكة';
          break;
        case 'operation-not-allowed':
          msg = 'تسجيل الدخول بالبريد غير مفعّل في Firebase Console';
          break;
        default:
          msg = 'حدث خطأ غير متوقع (${e.code})';
      }
      if (mounted) {
        _showSnack(msg, color: Colors.red.shade600, icon: Icons.error_outline);
      }
    } catch (e) {
      if (mounted) {
        _showSnack(
          'تعذر تسجيل الدخول: ${e.toString()}',
          color: Colors.red.shade600,
          icon: Icons.error_outline,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Sign in',
      child: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                onPressed: _signIn,
                child: const Text('Sign in'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final email = emailCtrl.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  _showSnack(
                    'اكتب بريدك الإلكتروني الأول',
                    color: Colors.red.shade600,
                    icon: Icons.error_outline,
                  );
                  return;
                }
                final ok = await context.read<ap.AuthProvider>().resetPassword(email);
                if (!mounted) return;
                _showSnack(
                  ok ? 'تم إرسال رابط إعادة التعيين' : 'تعذر إرسال رابط إعادة التعيين',
                  color: ok ? Colors.green.shade600 : Colors.red.shade600,
                  icon: ok ? Icons.check_circle_outline : Icons.error_outline,
                );
              },
              child: const Text('Forgot password?'),
            ),
          ],
        ),
      ),
    );
  }
}

