import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/helpers/team_query_helper.dart';
import '../data/helpers/user_query_helper.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/add_member_sheet.dart';
import '../widgets/team_form_sheet.dart';

const _managerRoles = {'MANAGER', 'ADMIN'};

// ── Data ──────────────────────────────────────────────────────────────────

class _TeamData {
  final Map<String, dynamic> team;
  final int myUserId;
  final bool canManage;

  _TeamData({
    required this.team,
    required this.myUserId,
    required this.canManage,
  });
}

// ── Screen ────────────────────────────────────────────────────────────────

class TeamDetailScreen extends StatefulWidget {
  final int teamId;
  final String? initialName;
  const TeamDetailScreen({super.key, required this.teamId, this.initialName});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  final _teamHelper = TeamQueryHelper();
  final _userHelper = UserQueryHelper();
  late Future<_TeamData> _future;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_TeamData> _loadData() async {
    final team = await _teamHelper.getTeamById(widget.teamId);
    final user = await _userHelper.getMe();
    final myUserId = (user['id'] as num).toInt();
    final myRole = ((user['teamMemberships'] as List?) ?? [])
        .cast<Map<String, dynamic>>()
        .where((m) => (m['teamId'] as num?)?.toInt() == widget.teamId)
        .map((m) => m['role'] as String?)
        .firstOrNull;
    return _TeamData(
      team: team,
      myUserId: myUserId,
      canManage: myRole != null && _managerRoles.contains(myRole),
    );
  }

  void _refresh() {
    _changed = true;
    setState(() => _future = _loadData());
  }

  void _snackError(Object e) {
    String? msg;
    if (e is DioException) msg = e.response?.data?['message'] as String?;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg ?? 'Erreur'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Future<void> _editTeam(Map<String, dynamic> team) async {
    final saved = await showTeamForm(context, existing: team);
    if (saved == true) _refresh();
  }

  Future<void> _deleteTeam(Map<String, dynamic> team) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.teamDeleteConfirm,
            style: GoogleFonts.exo2(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text(l10n.teamDeleteConfirmMessage(team['name'] as String? ?? ''),
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.teamDelete,
                style: GoogleFonts.exo2(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _teamHelper.deleteTeam(team['id'] as int);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _snackError(e);
    }
  }

  Future<void> _manageMember(Map<String, dynamic> member) async {
    final l10n = AppLocalizations.of(context)!;
    final userId = (member['id'] as num).toInt();
    final currentRole = _memberRole(member);
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(member['username'] as String? ?? '',
                style: GoogleFonts.exo2(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 16)),
            const SizedBox(height: 8),
            for (final role in const ['MEMBER', 'MANAGER', 'ADMIN'])
              ListTile(
                leading:
                    const Icon(Icons.shield_outlined, color: AppColors.primary),
                title: Text(_roleLabel(l10n, role),
                    style: const TextStyle(color: AppColors.textPrimary)),
                trailing: currentRole == role
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(ctx).pop('role:$role'),
              ),
            ListTile(
              leading: const Icon(Icons.person_remove_outlined,
                  color: AppColors.error),
              title: Text(l10n.memberRemove,
                  style: const TextStyle(color: AppColors.error)),
              onTap: () => Navigator.of(ctx).pop('remove'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (action == null) return;
    try {
      if (action == 'remove') {
        await _teamHelper.removeMember(widget.teamId, userId);
      } else if (action.startsWith('role:')) {
        await _teamHelper.updateMemberRole(
            widget.teamId, userId, action.split(':')[1]);
      }
      _refresh();
    } catch (e) {
      _snackError(e);
    }
  }

  Future<void> _addMember(List<Map<String, dynamic>> members) async {
    final l10n = AppLocalizations.of(context)!;
    final existing =
        members.map((m) => (m['id'] as num).toInt()).toSet();
    final userId = await showAddMemberSheet(context, excludeUserIds: existing);
    if (userId == null || !mounted) return;
    try {
      await _teamHelper.addMember(widget.teamId, userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.memberAdded),
          backgroundColor: AppColors.win,
        ));
      }
      _refresh();
    } catch (e) {
      _snackError(e);
    }
  }

  /// Rôle du membre dans CETTE équipe (depuis ses teamMemberships).
  String? _memberRole(Map<String, dynamic> member) {
    return ((member['teamMemberships'] as List?) ?? [])
        .cast<Map<String, dynamic>>()
        .where((m) => (m['teamId'] as num?)?.toInt() == widget.teamId)
        .map((m) => m['role'] as String?)
        .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textSecondary),
            onPressed: () => Navigator.of(context).pop(_changed),
          ),
          title: Text(
            widget.initialName ?? '',
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
          actions: [
            FutureBuilder<_TeamData>(
              future: _future,
              builder: (context, snap) {
                if (snap.data?.canManage != true) return const SizedBox.shrink();
                final team = snap.data!.team;
                return Row(children: [
                  IconButton(
                    onPressed: () => _editTeam(team),
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.textSecondary, size: 20),
                  ),
                  IconButton(
                    onPressed: () => _deleteTeam(team),
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error, size: 20),
                  ),
                ]);
              },
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: FutureBuilder<_TeamData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(l10n.teamLoadError,
                      style: const TextStyle(color: AppColors.textSecondary)),
                );
              }
              final data = snapshot.data!;
              final team = data.team;
              final members =
                  ((team['members'] as List?) ?? []).cast<Map<String, dynamic>>();
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Text(
                    team['name'] as String? ?? '',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (team['category'] != null)
                        _Chip(label: team['category'] as String),
                      if (team['gender'] != null)
                        _Chip(label: team['gender'] as String),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (team['clubName'] != null) ...[
                    _SectionTitle(text: l10n.teamClub),
                    const SizedBox(height: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              team['clubName'] as String,
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Row(children: [
                    Expanded(
                        child: _SectionTitle(
                            text:
                                '${l10n.teamMembers} (${members.length})')),
                    if (data.canManage)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary),
                        onPressed: () => _addMember(members),
                        icon: const Icon(Icons.person_add_alt_1, size: 18),
                        label: Text(l10n.memberAdd),
                      ),
                  ]),
                  const SizedBox(height: 8),
                  if (members.isEmpty)
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.teamNoMembers,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                      ),
                    )
                  else
                    ...members.map((m) {
                      final isMe = (m['id'] as num).toInt() == data.myUserId;
                      final tappable = data.canManage && !isMe;
                      return _MemberTile(
                        member: m,
                        role: _memberRole(m),
                        onTap: tappable ? () => _manageMember(m) : null,
                      );
                    }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

String _roleLabel(AppLocalizations l10n, String? role) => switch (role) {
      'ADMIN' => l10n.roleAdmin,
      'MANAGER' => l10n.roleManager,
      _ => l10n.roleMember,
    };

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      );
}

class _MemberTile extends StatelessWidget {
  final Map<String, dynamic> member;
  final String? role;
  final VoidCallback? onTap;
  const _MemberTile({required this.member, required this.role, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                (member['username'] as String? ?? '?')
                    .substring(0, 1)
                    .toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                member['username'] as String? ?? '',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
              ),
            ),
            const SizedBox(width: 8),
            _RoleBadge(label: _roleLabel(l10n, role)),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textSecondary),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;
  const _RoleBadge({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
            color: AppColors.primaryDim,
            borderRadius: BorderRadius.circular(4)),
        child: Text(label,
            style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      );
}
