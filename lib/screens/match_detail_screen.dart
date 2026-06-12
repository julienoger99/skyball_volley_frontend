import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/helpers/match_query_helper.dart';
import '../data/helpers/user_query_helper.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/match_form_sheet.dart';
import '../widgets/matchup_title.dart';

// ── Data ──────────────────────────────────────────────────────────────────

class _MatchDetailData {
  final Map<String, dynamic> match;
  final int myUserId;
  final bool canManage;

  _MatchDetailData({
    required this.match,
    required this.myUserId,
    required this.canManage,
  });
}

const _managerRoles = {'MANAGER', 'ADMIN'};

// ── Screen ────────────────────────────────────────────────────────────────

class MatchDetailScreen extends StatefulWidget {
  final int matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  final _matchHelper = MatchQueryHelper();
  final _userHelper = UserQueryHelper();
  late Future<_MatchDetailData> _future;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_MatchDetailData> _loadData() async {
    final match = await _matchHelper.getMatchById(widget.matchId);
    final user = await _userHelper.getMe();
    final myUserId = (user['id'] as num).toInt();
    final teamId = (match['team']?['id'] as num?)?.toInt();
    final memberships = (user['teamMemberships'] as List?) ?? [];
    final myRole = memberships
        .cast<Map<String, dynamic>>()
        .where((m) => (m['teamId'] as num?)?.toInt() == teamId)
        .map((m) => m['role'] as String?)
        .firstOrNull;
    return _MatchDetailData(
      match: match,
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

  Future<void> _editMatch(Map<String, dynamic> match) async {
    final saved = await showMatchForm(context, existing: match);
    if (saved == true) _refresh();
  }

  Future<void> _deleteMatch(Map<String, dynamic> match) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.matchDeleteConfirm,
            style: GoogleFonts.exo2(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text(l10n.matchDeleteConfirmMessage,
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
            child: Text(l10n.matchDelete,
                style: GoogleFonts.exo2(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _matchHelper.deleteMatch(match['id'] as int);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _snackError(e);
    }
  }

  // ── Set editing ──────────────────────────────────────────────────────────

  Future<void> _addOrEditSet(Map<String, dynamic> match,
      {Map<String, dynamic>? existing}) async {
    final sets = (match['sets'] as List?) ?? [];
    final nextNumber = sets.isEmpty
        ? 1
        : sets
                .map((s) => (s['setNumber'] as num).toInt())
                .reduce((a, b) => a > b ? a : b) +
            1;
    final result = await showDialog<_SetInput>(
      context: context,
      builder: (_) => _SetDialog(
        setNumber: existing != null
            ? (existing['setNumber'] as num).toInt()
            : nextNumber,
        teamPoints: (existing?['teamPoints'] as num?)?.toInt(),
        opponentPoints: (existing?['opponentPoints'] as num?)?.toInt(),
      ),
    );
    if (result == null) return;
    try {
      await _matchHelper.addOrUpdateSet(
        match['id'] as int,
        setNumber: result.setNumber,
        teamPoints: result.teamPoints,
        opponentPoints: result.opponentPoints,
      );
      _refresh();
    } catch (e) {
      _snackError(e);
    }
  }

  Future<void> _deleteSet(Map<String, dynamic> match, int setNumber) async {
    try {
      await _matchHelper.deleteSet(match['id'] as int, setNumber);
      _refresh();
    } catch (e) {
      _snackError(e);
    }
  }

  // ── Attendance & captain ───────────────────────────────────────────────────

  Future<void> _managePlayer(
      _MatchDetailData data, Map<String, dynamic> player) async {
    final isMe = (player['playerId'] as num).toInt() == data.myUserId;
    if (!data.canManage && !isMe) return;
    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(player['username'] as String? ?? '',
                style: GoogleFonts.exo2(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 16)),
            const SizedBox(height: 8),
            for (final status in const ['PRESENT', 'ABSENT', 'UNKNOWN'])
              ListTile(
                leading: Icon(_attendanceIcon(status),
                    color: _attendanceColor(status)),
                title: Text(_attendanceLabel(l10n, status),
                    style: const TextStyle(color: AppColors.textPrimary)),
                trailing: player['attendanceStatus'] == status
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(ctx).pop('attendance:$status'),
              ),
            if (data.canManage && player['captain'] != true)
              ListTile(
                leading: const Icon(Icons.star_outline, color: AppColors.primary),
                title: Text(l10n.matchSetCaptain,
                    style: const TextStyle(color: AppColors.textPrimary)),
                onTap: () => Navigator.of(ctx).pop('captain'),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ).then((action) async {
      if (action == null) return;
      final matchId = data.match['id'] as int;
      final playerId = (player['playerId'] as num).toInt();
      try {
        if (action == 'captain') {
          await _matchHelper.setCaptain(matchId, playerId);
        } else if (action.startsWith('attendance:')) {
          await _matchHelper.updateAttendance(
              matchId, playerId, action.split(':')[1]);
        }
        _refresh();
      } catch (e) {
        _snackError(e);
      }
    });
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
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: FutureBuilder<_MatchDetailData>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _withBar(const Center(
                      child: CircularProgressIndicator(color: AppColors.primary)));
                }
                if (snapshot.hasError) {
                  return _withBar(Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(l10n.matchLoadError,
                          style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => setState(() => _future = _loadData()),
                        child: Text(l10n.homeRetry,
                            style: const TextStyle(color: AppColors.primary)),
                      ),
                    ]),
                  ));
                }
                final data = snapshot.data!;
                final match = data.match;
                return Column(
                  children: [
                    _TopBar(
                      onBack: () => Navigator.of(context).pop(_changed),
                      onEdit:
                          data.canManage ? () => _editMatch(match) : null,
                      onDelete:
                          data.canManage ? () => _deleteMatch(match) : null,
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                        children: [
                          _MatchHeader(match: match),
                          const SizedBox(height: 24),
                          _SetsSection(
                            match: match,
                            canManage: data.canManage,
                            onAdd: () => _addOrEditSet(match),
                            onEdit: (s) => _addOrEditSet(match, existing: s),
                            onDelete: (n) => _deleteSet(match, n),
                          ),
                          const SizedBox(height: 24),
                          _PlayersSection(
                            data: data,
                            onTapPlayer: (p) => _managePlayer(data, p),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _withBar(Widget child) => Column(
        children: [
          _TopBar(onBack: () => Navigator.of(context).pop(_changed)),
          Expanded(child: child),
        ],
      );
}

// ── Attendance helpers ──────────────────────────────────────────────────────

IconData _attendanceIcon(String status) => switch (status) {
      'PRESENT' => Icons.check_circle_outline,
      'ABSENT' => Icons.cancel_outlined,
      _ => Icons.help_outline,
    };

Color _attendanceColor(String status) => switch (status) {
      'PRESENT' => AppColors.win,
      'ABSENT' => AppColors.error,
      _ => AppColors.textSecondary,
    };

String _attendanceLabel(AppLocalizations l10n, String status) => switch (status) {
      'PRESENT' => l10n.attendancePresent,
      'ABSENT' => l10n.attendanceAbsent,
      _ => l10n.attendanceUnknown,
    };

// ── Top bar ───────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const _TopBar({required this.onBack, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          const Spacer(),
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined,
                  color: AppColors.textSecondary, size: 20),
            ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 20),
            ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────

class _MatchHeader extends StatelessWidget {
  final Map<String, dynamic> match;
  const _MatchHeader({required this.match});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateTime.parse(match['matchDate']);
    final dateLabel = DateFormat('EEE d MMM yyyy • HH:mm', locale).format(date);
    final isHome = match['home'] == true;
    final location = match['location'] as String?;
    final championship = match['championship']?['name'] as String?;
    final coachMessage = match['coachMessage'] as String?;
    final status = match['status'] as String? ?? 'SCHEDULED';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceHigh, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _StatusBadge(status: status),
            const Spacer(),
            Icon(isHome ? Icons.home_outlined : Icons.flight_takeoff,
                size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(isHome ? l10n.homeHome : l10n.homeAway,
                style:
                    const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ]),
          const SizedBox(height: 14),
          MatchupTitle(match: match, fontSize: 20),
          const SizedBox(height: 14),
          _InfoRow(icon: Icons.calendar_today, text: dateLabel),
          if (location != null && location.isNotEmpty) ...[
            const SizedBox(height: 6),
            _InfoRow(icon: Icons.place_outlined, text: location),
          ],
          if (championship != null && championship.isNotEmpty) ...[
            const SizedBox(height: 6),
            _InfoRow(icon: Icons.emoji_events_outlined, text: championship),
          ],
          if (coachMessage != null && coachMessage.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(color: AppColors.uiBorder, height: 1),
            const SizedBox(height: 12),
            Text(coachMessage,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ),
      ]);
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (status) {
      'PLAYED' => l10n.matchStatusPlayed,
      'CANCELLED' => l10n.matchStatusCancelled,
      'POSTPONED' => l10n.matchStatusPostponed,
      'FORFEIT' => l10n.matchStatusForfeit,
      _ => l10n.matchStatusScheduled,
    };
    final color = switch (status) {
      'PLAYED' => AppColors.win,
      'CANCELLED' || 'FORFEIT' => AppColors.error,
      'POSTPONED' => AppColors.textSecondary,
      _ => AppColors.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(label,
          style: GoogleFonts.exo2(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Sets section ────────────────────────────────────────────────────────────

class _SetsSection extends StatelessWidget {
  final Map<String, dynamic> match;
  final bool canManage;
  final VoidCallback onAdd;
  final void Function(Map<String, dynamic> set) onEdit;
  final void Function(int setNumber) onDelete;

  const _SetsSection({
    required this.match,
    required this.canManage,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sets = ((match['sets'] as List?) ?? []).cast<Map<String, dynamic>>()
      ..sort((a, b) =>
          (a['setNumber'] as num).compareTo(b['setNumber'] as num));
    final teamSetsWon = (match['teamSetsWon'] as num?)?.toInt() ?? 0;
    final opponentSetsWon = (match['opponentSetsWon'] as num?)?.toInt() ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: _SectionHeader(title: l10n.matchSets)),
          Text('$teamSetsWon – $opponentSetsWon',
              style: GoogleFonts.exo2(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 12),
        if (sets.isEmpty)
          Text(l10n.matchNoSets,
              style: const TextStyle(color: AppColors.textSecondary))
        else
          ...sets.map((s) => _SetRow(
                set: s,
                canManage: canManage,
                onEdit: () => onEdit(s),
                onDelete: () => onDelete((s['setNumber'] as num).toInt()),
              )),
        if (canManage) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
            label: Text(l10n.matchAddSet,
                style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ],
    );
  }
}

class _SetRow extends StatelessWidget {
  final Map<String, dynamic> set;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _SetRow({
    required this.set,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final number = (set['setNumber'] as num).toInt();
    final tp = (set['teamPoints'] as num?)?.toInt() ?? 0;
    final op = (set['opponentPoints'] as num?)?.toInt() ?? 0;
    final won = tp > op;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.uiBorder, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text('${l10n.matchSet} $number',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text('$tp – $op',
                style: GoogleFonts.exo2(
                    color: won ? AppColors.win : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ),
          if (canManage) ...[
            IconButton(
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: AppColors.textSecondary),
            ),
            IconButton(
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
              icon:
                  const Icon(Icons.close, size: 18, color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Players section ─────────────────────────────────────────────────────────

class _PlayersSection extends StatelessWidget {
  final _MatchDetailData data;
  final void Function(Map<String, dynamic> player) onTapPlayer;
  const _PlayersSection({required this.data, required this.onTapPlayer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final players =
        ((data.match['players'] as List?) ?? []).cast<Map<String, dynamic>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: '${l10n.matchPlayers} (${players.length})'),
        const SizedBox(height: 12),
        if (players.isEmpty)
          Text(l10n.matchNoPlayers,
              style: const TextStyle(color: AppColors.textSecondary))
        else
          ...players.map((p) {
            final isMe = (p['playerId'] as num).toInt() == data.myUserId;
            final tappable = data.canManage || isMe;
            return _PlayerTile(
              player: p,
              highlightMe: isMe,
              onTap: tappable ? () => onTapPlayer(p) : null,
            );
          }),
      ],
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final Map<String, dynamic> player;
  final bool highlightMe;
  final VoidCallback? onTap;
  const _PlayerTile(
      {required this.player, required this.highlightMe, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final username = player['username'] as String? ?? '';
    final isCaptain = player['captain'] == true;
    final status = player['attendanceStatus'] as String? ?? 'UNKNOWN';
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlightMe
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.uiBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                (username.isNotEmpty ? username : '?')
                    .substring(0, 1)
                    .toUpperCase(),
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(children: [
                Flexible(
                  child: Text(username,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 15)),
                ),
                if (isCaptain) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.star, size: 14, color: AppColors.primary),
                  const SizedBox(width: 2),
                  Text(l10n.matchCaptain,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ]),
            ),
            const SizedBox(width: 8),
            _AttendanceChip(status: status),
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

class _AttendanceChip extends StatelessWidget {
  final String status;
  const _AttendanceChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _attendanceColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_attendanceIcon(status), size: 13, color: color),
        const SizedBox(width: 4),
        Text(_attendanceLabel(l10n, status),
            style:
                TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ── Set dialog ──────────────────────────────────────────────────────────────

class _SetInput {
  final int setNumber;
  final int teamPoints;
  final int opponentPoints;
  _SetInput(this.setNumber, this.teamPoints, this.opponentPoints);
}

class _SetDialog extends StatefulWidget {
  final int setNumber;
  final int? teamPoints;
  final int? opponentPoints;
  const _SetDialog(
      {required this.setNumber, this.teamPoints, this.opponentPoints});

  @override
  State<_SetDialog> createState() => _SetDialogState();
}

class _SetDialogState extends State<_SetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _team;
  late final TextEditingController _opp;

  @override
  void initState() {
    super.initState();
    _team = TextEditingController(text: widget.teamPoints?.toString() ?? '');
    _opp = TextEditingController(text: widget.opponentPoints?.toString() ?? '');
  }

  @override
  void dispose() {
    _team.dispose();
    _opp.dispose();
    super.dispose();
  }

  String? _validate(String? v) {
    if (v == null || v.trim().isEmpty) return AppLocalizations.of(context)!.fieldRequired;
    final n = int.tryParse(v.trim());
    if (n == null || n < 0) return AppLocalizations.of(context)!.fieldRequired;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('${l10n.matchSet} ${widget.setNumber}',
          style: GoogleFonts.exo2(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      content: Form(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _team,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(labelText: l10n.matchTeamPoints),
                validator: _validate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _opp,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration:
                    InputDecoration(labelText: l10n.matchOpponentPoints),
                validator: _validate,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel,
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(_SetInput(
              widget.setNumber,
              int.parse(_team.text.trim()),
              int.parse(_opp.text.trim()),
            ));
          },
          child: Text(l10n.champSave),
        ),
      ],
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: GoogleFonts.exo2(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ],
      );
}
