import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../data/helpers/auth_query_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/language_switcher.dart';

/// Two-phase flow: resend a verification email, then verify the account using
/// the code received by email.
class VerifyEmailScreen extends StatefulWidget {
  /// Pre-fills the email field when navigated to from a login "not verified"
  /// error or the register success dialog.
  final String? initialEmail;

  /// Starts directly on the "enter code" phase (e.g. right after registration,
  /// when the verification email has just been sent).
  final bool startVerifying;
  const VerifyEmailScreen(
      {super.key, this.initialEmail, this.startVerifying = false});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

enum _Phase { resend, verify }

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _authHelper = AuthQueryHelper();

  final _resendFormKey = GlobalKey<FormState>();
  final _verifyFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();

  _Phase _phase = _Phase.resend;
  bool _loading = false;
  String? _errorMessage;
  String? _infoMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
    if (widget.startVerifying) _phase = _Phase.verify;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'];
    return AppLocalizations.of(context)!.errorGeneric;
  }

  Future<void> _resend() async {
    if (!_resendFormKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await _authHelper.resendVerification(_emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _phase = _Phase.verify;
        _infoMessage = l10n.verifyResendSent;
      });
    } on DioException catch (e) {
      setState(() => _errorMessage = _parseError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    if (!_verifyFormKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await _authHelper.verifyEmail(_tokenController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.verifySuccess),
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
    final isResend = _phase == _Phase.resend;
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
                          isResend
                              ? Icons.mark_email_unread_outlined
                              : Icons.verified_outlined,
                          size: 56,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isResend ? l10n.verifyResendButton : l10n.verifyTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.exo2(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isResend
                              ? l10n.verifyResendPrompt
                              : l10n.verifySubtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 28),
                        if (_infoMessage != null) ...[
                          _InfoBanner(message: _infoMessage!),
                          const SizedBox(height: 16),
                        ],
                        if (isResend)
                          _buildResendForm(l10n)
                        else
                          _buildVerifyForm(l10n),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          _ErrorBanner(message: _errorMessage!),
                        ],
                        const SizedBox(height: 28),
                        ElevatedButton(
                          onPressed:
                              _loading ? null : (isResend ? _resend : _verify),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.background,
                                  ),
                                )
                              : Text(isResend
                                  ? l10n.verifyResendButton
                                  : l10n.verifyButton),
                        ),
                        const SizedBox(height: 16),
                        if (isResend)
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => setState(() {
                                      _phase = _Phase.verify;
                                      _errorMessage = null;
                                    }),
                            child: Text(
                              l10n.verifyHaveCode,
                              style: const TextStyle(color: AppColors.primary),
                            ),
                          )
                        else
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => Navigator.of(context).pop(),
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

  Widget _buildResendForm(AppLocalizations l10n) => Form(
        key: _resendFormKey,
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
          onFieldSubmitted: (_) => _resend(),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
              return l10n.registerEmailInvalid;
            }
            return null;
          },
        ),
      );

  Widget _buildVerifyForm(AppLocalizations l10n) => Form(
        key: _verifyFormKey,
        child: TextFormField(
          controller: _tokenController,
          decoration: InputDecoration(
            hintText: l10n.verifyToken,
            prefixIcon:
                const Icon(Icons.vpn_key_outlined, color: AppColors.textSecondary),
          ),
          autocorrect: false,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _verify(),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
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
