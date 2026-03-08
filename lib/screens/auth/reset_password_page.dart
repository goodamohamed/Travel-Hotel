import 'package:flutter/material.dart';
import '../../core/app_scope.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../shared/auth_scaffold.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});
  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final emailCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
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
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset password',
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
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty || !v.contains('@') ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  _showSnack('أدخل بريد إلكتروني صالح', color: Colors.red.shade600, icon: Icons.error_outline);
                  return;
                }
                final email = emailCtrl.text.trim();
                _showSnack('جاري الإرسال...', color: const Color(0xFF003B95), icon: Icons.email_outlined, duration: const Duration(seconds: 2));
                final app = AppScope.of(context);
                try {
                  if (app.firebaseReady) {
                    await fb.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  } else {
                    app.resetPassword(email);
                  }
                  _showSnack('تم إرسال رابط استعادة كلمة المرور', color: Colors.green.shade600, icon: Icons.check_circle_outline);
                  if (mounted) Navigator.pop(context);
                } on fb.FirebaseAuthException catch (e) {
                  String msg;
                  switch (e.code) {
                    case 'user-not-found':
                      msg = 'لا يوجد حساب بهذا البريد';
                      break;
                    case 'invalid-email':
                      msg = 'البريد الإلكتروني غير صالح';
                      break;
                    default:
                      msg = 'تعذر إرسال الرابط';
                  }
                  _showSnack(msg, color: Colors.red.shade600, icon: Icons.error_outline);
                } catch (_) {
                  _showSnack('حدث خطأ أثناء الإرسال', color: Colors.red.shade600, icon: Icons.error_outline);
                }
              },
              child: const Text('Send link'),
            ),
          ],
        ),
      ),
    );
  }
}
