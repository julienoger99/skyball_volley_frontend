import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/api_client.dart';
import '../../data/helpers/auth_query_helper.dart';
import '../../data/helpers/user_query_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';

// ── Data ──────────────────────────────────────────────────────────────────

class _ProfileData {
  final int userId;
  final String username;
  final String email;
  final int teamCount;
  final String? clubName;

  _ProfileData({
    required this.userId,
    required this.username,
    required this.email,
    required this.teamCount,
    required this.clubName,
  });
}

// ── Tab root ──────────────────────────────────────────────────────────────

class ProfileTab extends StatefulWidget {
  final void Function(int) onNavigate;
  const ProfileTab({super.key, required this.onNavigate});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _userHelper = UserQueryHelper();
  final _authHelper = AuthQueryHelper();
  late Future<_ProfileData> _future;
  bool _loggingOut = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_ProfileData> _loadData() async {
    final user = await _userHelper.getMe();
    final teamMemberships = (user['teamMemberships'] as List?) ?? [];
    final clubMemberships = (user['clubMemberships'] as List?) ?? [];
    final clubName = clubMemberships.isNotEmpty
        ? clubMemberships[0]['clubName'] as String?
        : null;
    return _ProfileData(
      userId: (user['id'] as num).toInt(),
      username: user['username'] as String,
      email: user['email'] as String,
      teamCount: teamMemberships.length,
      clubName: clubName,
    );
  }

  Future<void> _showEditDialog(BuildContext context, _ProfileData data) async {
    final l10n = AppLocalizations.of(context)!;
    final usernameCtrl = TextEditingController(text: data.username);
    final emailCtrl = TextEditingController(text: data.email);
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(l10n.profileEdit,
              style: GoogleFonts.exo2(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          content: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _DialogField(
                controller: usernameCtrl,
                label: l10n.registerUsername,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 14),
              _DialogField(
                controller: emailCtrl,
                label: l10n.registerEmail,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                    return l10n.registerEmailInvalid;
                  }
                  return null;
                },
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDeep),
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setS(() => saving = true);
                      try {
                        await _userHelper.updateUser(
                          data.userId,
                          username: usernameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                        );
                        if (ctx.mounted) Navigator.of(ctx).pop(true);
                      } on DioException catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                            content: Text(
                                e.response?.data?['message'] ?? 'Erreur'),
                            backgroundColor: AppColors.error,
                          ));
                        }
                        setS(() => saving = false);
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: AppColors.backgroundDeep, strokeWidth: 2))
                  : Text(l10n.confirm,
                      style:
                          GoogleFonts.exo2(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
    if (saved == true) setState(() => _future = _loadData());
  }

  Future<void> _deleteAccount(BuildContext context, _ProfileData data) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.profileDeleteConfirm,
            style: GoogleFonts.exo2(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        content: Text(l10n.profileDeleteMessage,
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.profileDeleteButton,
                style: GoogleFonts.exo2(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    setState(() => _deleting = true);
    try {
      await _userHelper.deleteUser(data.userId);
    } on DioException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.response?.data?['message'] ?? 'Erreur'),
          backgroundColor: AppColors.error,
        ));
        setState(() => _deleting = false);
      }
      return;
    }
    await deleteToken();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.profileLogoutConfirm,
            style: GoogleFonts.exo2(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        content: Text(l10n.profileLogoutMessage,
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.profileLogout,
                style: GoogleFonts.exo2(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    setState(() => _loggingOut = true);
    try {
      await _authHelper.logout();
    } on DioException catch (_) {
      // ignore logout errors — clear session anyway
    }
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration:
          const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: FutureBuilder<_ProfileData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(l10n.homeLoadError,
                    style: const TextStyle(
                        color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      setState(() => _future = _loadData()),
                  child: Text(l10n.homeRetry,
                      style:
                          const TextStyle(color: AppColors.primary)),
                ),
              ]),
            );
          }
          final data = snapshot.data!;
          return _ProfileBody(
            data: data,
            loggingOut: _loggingOut,
            deleting: _deleting,
            onEdit: () => _showEditDialog(context, data),
            onLogout: () => _logout(context),
            onDelete: () => _deleteAccount(context, data),
            onNavigateTeams: () => widget.onNavigate(2),
            onNavigateClub: () => widget.onNavigate(3),
          );
        },
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────

class _ProfileBody extends StatelessWidget {
  final _ProfileData data;
  final bool loggingOut;
  final bool deleting;
  final VoidCallback onEdit;
  final VoidCallback onLogout;
  final VoidCallback onDelete;
  final VoidCallback onNavigateTeams;
  final VoidCallback onNavigateClub;

  const _ProfileBody({
    required this.data,
    required this.loggingOut,
    required this.deleting,
    required this.onEdit,
    required this.onLogout,
    required this.onDelete,
    required this.onNavigateTeams,
    required this.onNavigateClub,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final initials =
        data.username.isNotEmpty ? data.username[0].toUpperCase() : '?';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
      children: [
        // Avatar + edit button
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryDim,
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 2),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.exo2(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: -4,
                child: GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceHigh,
                      border: Border.all(
                          color: AppColors.uiBorder, width: 1.5),
                    ),
                    child: const Icon(Icons.edit,
                        size: 14, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Username
        Center(
          child: Text(
            data.username,
            style: GoogleFonts.exo2(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 6),

        // Email
        Center(
          child: Text(
            data.email,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
        const SizedBox(height: 28),

        // Stats chips
        Center(
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _StatChip(
                icon: Icons.group_outlined,
                label: l10n.profileTeams(data.teamCount),
                onTap: onNavigateTeams,
              ),
              if (data.clubName != null)
                _StatChip(
                  icon: Icons.domain_outlined,
                  label: data.clubName!,
                  onTap: onNavigateClub,
                ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        const Divider(color: AppColors.uiBorder, height: 1),
        const SizedBox(height: 32),

        // Logout
        Center(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error, width: 1),
              minimumSize: const Size(200, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: loggingOut ? null : onLogout,
            icon: loggingOut
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: AppColors.error, strokeWidth: 2))
                : const Icon(Icons.logout, size: 18),
            label: Text(l10n.profileLogout,
                style:
                    GoogleFonts.exo2(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 32),

        // Danger zone — delete account
        Text(
          l10n.profileDangerZone.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              minimumSize: const Size(200, 44),
            ),
            onPressed: deleting ? null : onDelete,
            icon: deleting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        color: AppColors.error, strokeWidth: 2))
                : const Icon(Icons.delete_forever_outlined, size: 18),
            label: Text(l10n.profileDeleteAccount,
                style: GoogleFonts.exo2(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

// ── Micro-widgets ─────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _StatChip({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: onTap != null
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.uiBorder,
              width: 1,
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                size: 15,
                color: onTap != null
                    ? AppColors.primary
                    : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: onTap != null
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right,
                  size: 14, color: AppColors.primary),
            ],
          ]),
        ),
      );
}

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const _DialogField(
      {required this.controller,
      required this.label,
      this.keyboardType,
      this.validator});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          filled: true,
          fillColor: AppColors.surfaceHigh,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.uiBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.uiBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
        ),
      );
}
