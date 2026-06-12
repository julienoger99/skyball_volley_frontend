import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../data/helpers/auth_query_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/language_switcher.dart';
import 'forgot_password_screen.dart';
import 'main_scaffold.dart';
import 'register_screen.dart';
import 'verify_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authHelper = AuthQueryHelper();

  bool _loading = false;
  bool _passwordVisible = false;
  bool _notVerified = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
      _notVerified = false;
    });
    try {
      await _authHelper.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } on DioException catch (e) {
      setState(() {
        _errorMessage = _parseError(e);
        _notVerified = e.response?.statusCode == 403;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _parseError(DioException e) {
    final l10n = AppLocalizations.of(context)!;
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'];
    switch (e.response?.statusCode) {
      case 401: return l10n.loginErrorInvalidCredentials;
      case 403: return l10n.loginErrorNotVerified;
      default:  return l10n.loginErrorGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(top: 12, right: 16, child: LanguageSwitcher()),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 32),
                          _Logo(),
                          const SizedBox(height: 20),
                          _AppTitle(),
                          const SizedBox(height: 8),
                          Text(
                            l10n.appSubtitle,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              letterSpacing: 2.5,
                            ),
                          ),
                          const SizedBox(height: 48),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: l10n.loginUsername,
                              prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                            ),
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            decoration: InputDecoration(
                              hintText: l10n.loginPassword,
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible ? Icons.visibility_off : Icons.visibility,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? l10n.fieldRequired : null,
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 14),
                            _ErrorBanner(message: _errorMessage!),
                          ],
                          if (_notVerified) ...[
                            const SizedBox(height: 4),
                            TextButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => VerifyEmailScreen(
                                    initialEmail:
                                        _usernameController.text.contains('@')
                                            ? _usernameController.text.trim()
                                            : null,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.mark_email_unread_outlined,
                                  size: 18, color: AppColors.primary),
                              label: Text(
                                l10n.verifyResendButton,
                                style: const TextStyle(color: AppColors.primary),
                              ),
                            ),
                          ],
                          const SizedBox(height: 28),
                          ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.background,
                                    ),
                                  )
                                : Text(l10n.loginButton),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen()),
                            ),
                            child: Text(
                              l10n.loginForgotPassword,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.loginNoAccount,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                ),
                                child: Text(
                                  l10n.loginCreateAccount,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [AppColors.surfaceHigh, AppColors.surface],
            radius: 0.85,
          ),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.55),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Text('🏐', style: TextStyle(fontSize: 44)),
        ),
      );
}

class _AppTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [AppColors.primary, Color(0xFFFFEA6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
        blendMode: BlendMode.srcIn,
        child: Text(
          'SKYBALL',
          style: GoogleFonts.exo2(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: 8,
            color: Colors.white,
          ),
        ),
      );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: Text(
          message,
          style: const TextStyle(color: AppColors.error, fontSize: 13),
        ),
      );
}
