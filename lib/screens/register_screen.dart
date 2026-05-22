import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _gmailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _usernameCtrl.dispose();
    _gmailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final name = _nameCtrl.text.trim();
    final surname = _surnameCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final email = _gmailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirmPassword = _confirmPasswordCtrl.text;

    // Validations
    if (name.isEmpty) {
      _showError('Please enter your name');
      return;
    }
    if (username.isEmpty) {
      _showError('Please enter a username');
      return;
    }
    if (email.isEmpty) {
      _showError('Please enter your email');
      return;
    }
    if (!email.contains('@')) {
      _showError('Please enter a valid email address');
      return;
    }
    if (password.isEmpty) {
      _showError('Please enter a password');
      return;
    }
    if (password.length < 4) {
      _showError('Password must be at least 4 characters');
      return;
    }
    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 600), () async {
      final error = await AuthService().register(name, surname, username, email, password);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (error != null) {
        _showError(error);
        return;
      }

      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Expanded(child: Text('Registration successful! Please log in.')),
            ],
          ),
          backgroundColor: const Color(0xFF27AE60),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.of(context).pop();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFE74C3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
          body: SafeArea(
            child: Stack(
              children: [
                // Main content
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: FadeTransition(
                            opacity: _fadeAnim,
                            child: SlideTransition(
                              position: _slideAnim,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 10),
                                  // Logo centered with optional orange blur
                                  Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (isDark)
                                          Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFC2713A).withValues(alpha: 0.35),
                                                  blurRadius: 60,
                                                  spreadRadius: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        Image.asset(
                                          'assets/images/logo.png',
                                          width: 160,
                                          fit: BoxFit.contain,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Form fields
                                  _buildField(_nameCtrl, 'name'),
                                  const SizedBox(height: 14),
                                  _buildField(_surnameCtrl, 'surname'),
                                  const SizedBox(height: 14),
                                  _buildField(_usernameCtrl, 'username'),
                                  const SizedBox(height: 14),
                                  _buildField(_gmailCtrl, 'gmail'),
                                  const SizedBox(height: 14),
                                  _buildPassField(
                                    _passwordCtrl,
                                    'password',
                                    _obscurePass,
                                    () => setState(
                                        () => _obscurePass = !_obscurePass),
                                  ),
                                  const SizedBox(height: 14),
                                  _buildPassField(
                                    _confirmPasswordCtrl,
                                    'confirm password',
                                    _obscureConfirm,
                                    () => setState(
                                        () => _obscureConfirm = !_obscureConfirm),
                                  ),
                                  const SizedBox(height: 28),
                                  // Register button
                                  SizedBox(
                                    width: 160,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFC2713A),
                                        foregroundColor: Colors.white,
                                        elevation: 2,
                                        shadowColor: const Color(0x40C2713A),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Register',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Back button
                Positioned(
                  top: 12,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: ThemeColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC2713A).withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFC2713A).withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFFC2713A),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: TextStyle(fontSize: 14, color: ThemeColors.inputText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: ThemeColors.inputHint),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide:
              const BorderSide(color: Color(0xFFC2713A), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide:
              const BorderSide(color: Color(0xFFC2713A), width: 2.0),
        ),
      ),
    );
  }

  Widget _buildPassField(TextEditingController ctrl, String hint,
      bool obscure, VoidCallback toggle) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: TextStyle(fontSize: 14, color: ThemeColors.inputText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: ThemeColors.inputHint),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: ThemeColors.textSecondary,
            size: 20,
          ),
          onPressed: toggle,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide:
              const BorderSide(color: Color(0xFFC2713A), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide:
              const BorderSide(color: Color(0xFFC2713A), width: 2.0),
        ),
      ),
    );
  }
}
