import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../theme/app_theme.dart';
import 'auth/reset_password_page.dart';

// ─── Login Screen ─────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  final VoidCallback onRegisterTap;
  const LoginScreen({super.key, required this.onRegisterTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<ap.AuthProvider>();
    await auth.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  Future<void> _resetPassword() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordPage(initialEmail: _emailController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────
            Container(
              height: 280,
              width: double.infinity,
              decoration:
                  const BoxDecoration(gradient: AppTheme.primaryGradient),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white30, width: 2)),
                      child: const Icon(Icons.flight_takeoff,
                          color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text('TravelMate',
                        style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text('Sign in to continue exploring',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ),

            // ── Form ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Welcome Back!',
                        style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 6),
                    const Text('Enter your credentials to continue',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 14)),
                    const SizedBox(height: 28),

                    // Email
                    _AuthField(
                      label: 'Email Address',
                      controller: _emailController,
                      hint: 'you@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v != null && v.contains('@')
                          ? null
                          : 'Enter a valid email',
                    ),
                    const SizedBox(height: 16),

                    // Password
                    _AuthField(
                      label: 'Password',
                      controller: _passwordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.textSecondary,
                            size: 20),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) => v != null && v.length >= 6
                          ? null
                          : 'Password must be 6+ characters',
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                                value: _rememberMe,
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v!),
                                activeColor: AppTheme.primary,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap),
                            const Text('Remember me',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                        GestureDetector(
                          onTap: _resetPassword,
                          child: const Text('Forgot Password?',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Error Message
                    Consumer<ap.AuthProvider>(
                      builder: (_, auth, __) => auth.errorMessage != null
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                  color:
                                      AppTheme.wishlistColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppTheme.wishlistColor
                                          .withOpacity(0.3))),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppTheme.wishlistColor, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(auth.errorMessage!,
                                          style: const TextStyle(
                                              color: AppTheme.wishlistColor,
                                              fontSize: 13))),
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ),

                    // Sign In Button
                    Consumer<ap.AuthProvider>(
                      builder: (_, auth, __) => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.status == ap.AuthStatus.loading
                              ? null
                              : _signIn,
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          child: auth.status == ap.AuthStatus.loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Sign In',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ",
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 14)),
                        GestureDetector(
                          onTap: widget.onRegisterTap,
                          child: const Text('Sign Up',
                              style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Register Screen 
class RegisterScreen extends StatefulWidget {
  final VoidCallback onLoginTap;
  const RegisterScreen({super.key, required this.onLoginTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please accept the Terms & Conditions')));
      return;
    }
    await context.read<ap.AuthProvider>().signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: widget.onLoginTap,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Account',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              const Text('Join TravelMate and start exploring!',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 30),

              _AuthField(
                  label: 'Full Name',
                  controller: _nameController,
                  hint: 'John Doe',
                  icon: Icons.person_outline,
                  validator: (v) => v != null && v.length >= 2
                      ? null
                      : 'Enter your full name'),
              const SizedBox(height: 16),
              _AuthField(
                  label: 'Email Address',
                  controller: _emailController,
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v != null && v.contains('@')
                      ? null
                      : 'Enter a valid email'),
              const SizedBox(height: 16),
              _AuthField(
                label: 'Password',
                controller: _passwordController,
                hint: 'Min 6 characters',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.textSecondary,
                      size: 20),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) => v != null && v.length >= 6
                    ? null
                    : 'Password must be 6+ characters',
              ),
              const SizedBox(height: 16),
              _AuthField(
                label: 'Confirm Password',
                controller: _confirmController,
                hint: 'Repeat your password',
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (v) => v == _passwordController.text
                    ? null
                    : 'Passwords do not match',
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (v) => setState(() => _agreedToTerms = v!),
                    activeColor: AppTheme.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                          children: [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600)),
                            TextSpan(text: ' and '),
                            TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Error
              Consumer<ap.AuthProvider>(
                builder: (_, auth, __) => auth.errorMessage != null
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: AppTheme.wishlistColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          const Icon(Icons.error_outline,
                              color: AppTheme.wishlistColor, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(auth.errorMessage!,
                                  style: const TextStyle(
                                      color: AppTheme.wishlistColor,
                                      fontSize: 13))),
                        ]),
                      )
                    : const SizedBox(),
              ),

              Consumer<ap.AuthProvider>(
                builder: (_, auth, __) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        auth.status == ap.AuthStatus.loading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    child: auth.status == ap.AuthStatus.loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Create Account',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                  GestureDetector(
                    onTap: widget.onLoginTap,
                    child: const Text('Sign In',
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Auth Gate (Login or Register toggle) ────────────────────────────────
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showLogin = true;
  @override
  Widget build(BuildContext context) {
    return _showLogin
        ? LoginScreen(onRegisterTap: () => setState(() => _showLogin = false))
        : RegisterScreen(onLoginTap: () => setState(() => _showLogin = true));
  }
}

// ─── Shared Auth Field Widget ─────────────────────────────────────────────
class _AuthField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _AuthField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
