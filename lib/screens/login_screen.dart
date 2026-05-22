import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/theme_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (username.isEmpty) { _showError('Please enter your username'); return; }
    if (password.isEmpty) { _showError('Please enter your password'); return; }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 600), () async {
      final error = await AuthService().login(username, password);
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (error != null) { _showError(error); return; }
      await CartService().reloadForUser();
      await OrderService().reloadForUser();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (c, a, s) => const HomeScreen(),
        transitionsBuilder: (c, a, s, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ));
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 20),
        const SizedBox(width: 10), Expanded(child: Text(msg)),
      ]),
      backgroundColor: const Color(0xFFE74C3C),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
        const SizedBox(width: 10), Expanded(child: Text(msg)),
      ]),
      backgroundColor: const Color(0xFF34C759),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _handleForgotPassword() {
    final usernameCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscureNew = true, obscureConfirm = true;
    int step = 1;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setS) {
          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            decoration: BoxDecoration(
              color: ThemeColors.bottomSheet,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(
                  color: ThemeColors.border, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 24),
                Container(width: 64, height: 64, decoration: BoxDecoration(
                  color: const Color(0xFFC2713A).withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(step == 1 ? Icons.person_search_rounded : Icons.lock_reset_rounded,
                    color: const Color(0xFFC2713A), size: 30)),
                const SizedBox(height: 16),
                Text(step == 1 ? 'Reset Password' : 'Set New Password',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ThemeColors.text)),
                const SizedBox(height: 6),
                Text(step == 1 ? 'Enter your username to continue' : 'Create a new password for your account',
                  style: TextStyle(fontSize: 13, color: ThemeColors.textSecondary)),
                const SizedBox(height: 24),
                if (step == 1) ...[
                  _buildResetField(usernameCtrl, 'Username', Icons.person_outline),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                    onPressed: () { if (usernameCtrl.text.trim().isEmpty) return; setS(() => step = 2); },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC2713A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                    child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  )),
                ] else ...[
                  _buildResetPassField(newPassCtrl, 'New Password', obscureNew,
                    () => setS(() => obscureNew = !obscureNew)),
                  const SizedBox(height: 12),
                  _buildResetPassField(confirmPassCtrl, 'Confirm New Password', obscureConfirm,
                    () => setS(() => obscureConfirm = !obscureConfirm)),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                    onPressed: isSubmitting ? null : () async {
                      final np = newPassCtrl.text.trim();
                      final cp = confirmPassCtrl.text.trim();
                      if (np.isEmpty) { Navigator.pop(ctx); _showError('Please enter a new password'); return; }
                      if (np.length < 4) { Navigator.pop(ctx); _showError('Password must be at least 4 characters'); return; }
                      if (np != cp) { Navigator.pop(ctx); _showError('Passwords do not match'); return; }
                      setS(() => isSubmitting = true);
                      final err = await AuthService().resetPassword(usernameCtrl.text.trim(), np);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (err != null) { _showError(err); } else { _showSuccess('Password reset successfully!'); }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC2713A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                    child: isSubmitting
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Text('Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  )),
                ],
                const SizedBox(height: 12),
              ]),
            ),
          );
        });
      },
    );
  }

  Widget _buildResetField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      style: TextStyle(fontSize: 14, color: ThemeColors.inputText),
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(fontSize: 14, color: ThemeColors.inputHint),
        prefixIcon: Icon(icon, color: ThemeColors.textSecondary, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ThemeColors.border, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC2713A), width: 2.0)),
      ),
    );
  }

  Widget _buildResetPassField(TextEditingController ctrl, String hint, bool obscure, VoidCallback toggle) {
    return TextField(
      controller: ctrl, obscureText: obscure,
      style: TextStyle(fontSize: 14, color: ThemeColors.inputText),
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(fontSize: 14, color: ThemeColors.inputHint),
        prefixIcon: Icon(Icons.lock_outline, color: ThemeColors.textSecondary, size: 20),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: ThemeColors.textSecondary, size: 20),
          onPressed: toggle),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ThemeColors.border, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC2713A), width: 2.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isDarkMode,
      builder: (context, isDark, child) {
        return Scaffold(
          backgroundColor: ThemeColors.scaffoldAlt,
          body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: FadeTransition(opacity: _fadeAnimation,
                  child: SlideTransition(position: _slideAnimation,
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const SizedBox(height: 30),
                      Stack(alignment: Alignment.center, children: [
                        if (isDark) Container(width: 180, height: 180, decoration: BoxDecoration(
                          shape: BoxShape.circle, boxShadow: [BoxShadow(
                            color: const Color(0xFFC2713A).withValues(alpha: 0.35),
                            blurRadius: 80, spreadRadius: 25)])),
                        Image.asset('assets/images/logo.png', width: 250, fit: BoxFit.contain),
                      ]),
                      const SizedBox(height: 30),
                      _buildTextField(_usernameController, 'username'),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 8),
                      _buildForgotPassword(),
                      const SizedBox(height: 24),
                      _buildLoginButton(),
                      const SizedBox(height: 16),
                      _buildRegisterLink(),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ),
            ));
          })),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return TextField(controller: ctrl,
      style: TextStyle(fontSize: 14, color: ThemeColors.inputText),
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(fontSize: 14, color: ThemeColors.inputHint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0xFFC2713A), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0xFFC2713A), width: 2.0)),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(controller: _passwordController, obscureText: _obscurePassword,
      style: TextStyle(fontSize: 14, color: ThemeColors.inputText),
      decoration: InputDecoration(
        hintText: 'Password', hintStyle: TextStyle(fontSize: 14, color: ThemeColors.inputHint),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: ThemeColors.textSecondary, size: 20),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0xFFC2713A), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0xFFC2713A), width: 2.0)),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _handleForgotPassword,
        style: TextButton.styleFrom(padding: EdgeInsets.zero,
          minimumSize: const Size(0, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
        child: const Text('forgot password?',
          style: TextStyle(fontSize: 12, color: Color(0xFFC2713A), fontStyle: FontStyle.italic)),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(width: 160, height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC2713A),
          foregroundColor: Colors.white, elevation: 2, shadowColor: const Color(0x40C2713A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
        child: _isLoading
          ? const SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
          : const Text('log in', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (c, a, s) => const RegisterScreen(),
          transitionsBuilder: (c, a, s, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeInOut)), child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ));
      },
      child: Text('register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
        color: ThemeColors.text, letterSpacing: 1)),
    );
  }
}
