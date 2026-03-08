import 'package:flutter/material.dart';
import '../../core/app_scope.dart';
import 'register_page.dart';
import 'reset_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
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
                border: OutlineInputBorder(),
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
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => obscure = !obscure),
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                ),
              ),
              validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final email = emailCtrl.text.trim();
                final pass = passCtrl.text;
                final valid = formKey.currentState!.validate();
                if (!valid) {
                  if (email.isEmpty || !email.contains('@')) {
                    _showSnack('من فضلك أدخل بريد إلكتروني صالح', color: Colors.red.shade600, icon: Icons.error_outline);
                  } else if (pass.length < 6) {
                    _showSnack('كلمة المرور يجب أن تكون 6 أحرف على الأقل', color: Colors.red.shade600, icon: Icons.error_outline);
                  } else {
                    _showSnack('رجاءً صحّح الحقول المظللة', color: Colors.red.shade600, icon: Icons.error_outline);
                  }
                  return;
                }
                _showSnack('جاري تسجيل الدخول...', color: const Color(0xFF003B95), icon: Icons.login, duration: const Duration(seconds: 2));
                final app = AppScope.of(context);
                try {
                  if (app.firebaseReady) {
                    await fb.FirebaseAuth.instance
                        .signInWithEmailAndPassword(email: email, password: pass);
                  } else {
                    app.signIn(email: email, password: pass);
                  }
                  _showSnack('تم تسجيل الدخول بنجاح',
                      color: Colors.green.shade600, icon: Icons.check_circle_outline);
                  if (mounted) Navigator.pop(context);
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
                  _showSnack(msg, color: Colors.red.shade600, icon: Icons.error_outline);
                } catch (e) {
                  _showSnack(
                    'تعذر تسجيل الدخول: ${e.toString()}',
                    color: Colors.red.shade600,
                    icon: Icons.error_outline,
                  );
                }
              },
              child: const Text('Sign in'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
                );
              },
              child: const Text('Forgot password?'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
