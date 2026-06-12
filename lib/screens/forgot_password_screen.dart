import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../data/helpers/auth_query_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/language_switcher.dart';

/// Two-phase flow: request a reset link by email, then reset the password
/// using the code received by email.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

enum _Phase { request, reset }

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authHelper = AuthQueryHelper();

  final _requestFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  _Phase _phase = _Phase.request;
  bool _loading = false;
  bool _passwordVisible = false;
  String? _errorMessage;
  String? _infoMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'];
    return AppLocalizations.of(context)!.errorGeneric;
  }

  Future<void> _sendLink() async {
    if (!_requestFormKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await _authHelper.forgotPassword(_emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _phase = _Phase.reset;
        _infoMessage = l10n.forgotSent;
      });
    } on DioException catch (e) {
      setState(() => _errorMessage = _parseError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await _authHelper.resetPassword(
        _tokenController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.resetSuccess),
        backgroundColor: AppColors.win,
      ));
      Navigator.of(context).pop();
    } on DioException catch (e) {
      setState(() => _errorMessage = _parseError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRequest = _phase == _Phase.request;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 4,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const Positioned(top: 12, right: 16, child: LanguageSwitcher()),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        Icon(
                          isRequest
                              ? Icons.lock_reset_outlined
                              : Icons.password_outlined,
                          size: 56,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isRequest ? l10n.forgotTitle : l10n.resetTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.exo2(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isRequest ? l10n.forgotSubtitle : l10n.resetSubtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 28),
                        if (_infoMessage != null) ...[
                          _InfoBanner(message: _infoMessage!),
                          const SizedBox(height: 16),
                        ],
                        if (isRequest) _buildRequestForm(l10n) else _buildResetForm(l10n),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          _ErrorBanner(message: _errorMessage!),
                        ],
                        const SizedBox(height: 28),
                        ElevatedButton(
                          onPressed: _loading
                              ? null
                              : (isRequest ? _sendLink : _resetPassword),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.background,
                                  ),
                                )
                              : Text(isRequest
                                  ? l10n.forgotSendButton
                                  : l10n.resetButton),
                        ),
                        const SizedBox(height: 16),
                        if (isRequest)
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => setState(() {
                                      _phase = _Phase.reset;
                                      _errorMessage = null;
                                    }),
                            child: Text(
                              l10n.forgotHaveCode,
                              style: const TextStyle(color: AppColors.primary),
                            ),
                          )
                        else
                          TextButton(
                            onPressed:
                                _loading ? null : () => Navigator.of(context).pop(),
                            child: Text(
                              l10n.backToLogin,
                              style: const TextStyle(color: AppColors.primary),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
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

  Widget _buildRequestForm(AppLocalizations l10n) => Form(
        key: _requestFormKey,
        child: TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: l10n.registerEmail,
            prefixIcon: const Icon(Icons.email_outlined,
                color: AppColors.textSecondary),
          ),
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _sendLink(),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
              return l10n.registerEmailInvalid;
            }
            return null;
          },
        ),
      );

  Widget _buildResetForm(AppLocalizations l10n) => Form(
        key: _resetFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _tokenController,
              decoration: InputDecoration(
                hintText: l10n.resetToken,
                prefixIcon: const Icon(Icons.vpn_key_outlined,
                    color: AppColors.textSecondary),
              ),
              autocorrect: false,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                hintText: l10n.resetNewPassword,
                prefixIcon: const Icon(Icons.lock_outline,
                    color: AppColors.textSecondary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _passwordVisible = !_passwordVisible),
                ),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.fieldRequired;
                if (v.length < 6) return l10n.registerPasswordTooShort;
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                hintText: l10n.resetConfirmPassword,
                prefixIcon: const Icon(Icons.lock_outline,
                    color: AppColors.textSecondary),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _resetPassword(),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.fieldRequired;
                if (v != _passwordController.text) {
                  return l10n.registerPasswordMismatch;
                }
                return null;
              },
            ),
          ],
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

class _InfoBanner extends StatelessWidget {
  final String message;
  const _InfoBanner({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.mark_email_read_outlined,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13),
              ),
            ),
          ],
        ),
      );
}
