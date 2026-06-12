import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/helpers/club_query_helper.dart';
import '../../data/helpers/team_query_helper.dart';
import '../../data/helpers/user_query_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/add_member_sheet.dart';
import '../../widgets/club_form_sheet.dart';
import '../../widgets/team_form_sheet.dart';
import '../team_detail_screen.dart';

const _managerRoles = {'MANAGER', 'ADMIN'};

// ── Data ──────────────────────────────────────────────────────────────────

class _ClubData {
  final Map<String, dynamic>? clubMembership;
  final Map<String, dynamic>? clubDetails;
  final List<Map<String, dynamic>> clubTeams;
  final List<Map<String, dynamic>> clubMembers;
  final Set<int> myTeamIds;
  final int userId;

  _ClubData({
    required this.clubMembership,
    required this.clubDetails,
    required this.clubTeams,
    required this.clubMembers,
    required this.myTeamIds,
    required this.userId,
  });

  bool get hasClub => clubMembership != null;

  bool get canManage =>
      _managerRoles.contains(clubMembership?['role'] as String?);
}

// ── Tab root ──────────────────────────────────────────────────────────────

class ClubTab extends StatefulWidget {
  const ClubTab({super.key});

  @override
  State<ClubTab> createState() => _ClubTabState();
}

class _ClubTabState extends State<ClubTab> {
  final _userHelper = UserQueryHelper();
  final _clubHelper = ClubQueryHelper();
  final _teamHelper = TeamQueryHelper();
  late Future<_ClubData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_ClubData> _loadData() async {
    final user = await _userHelper.getMe();
    final userId = user['id'] as int;
    final clubMemberships = (user['clubMemberships'] as List?) ?? [];
    final myTeamIds = ((user['teamMemberships'] as List?) ?? [])
        .map((m) => (m['teamId'] as num).toInt())
        .toSet();

    if (clubMemberships.isEmpty) {
      return _ClubData(
        clubMembership: null,
        clubDetails: null,
        clubTeams: [],
        clubMembers: [],
        myTeamIds: myTeamIds,
        userId: userId,
      );
    }

    final membership = clubMemberships[0] as Map<String, dynamic>;
    final clubId = membership['clubId'] as int;
    final clubDetails = await _clubHelper.getClubById(clubId);
    final clubTeams = (await _teamHelper.getTeamsByClub(clubId, size: 50))
        .cast<Map<String, dynamic>>();
    final clubMembers = (await _clubHelper.getClubMembers(clubId))
        .cast<Map<String, dynamic>>();

    return _ClubData(
      clubMembership: membership,
      clubDetails: clubDetails,
      clubTeams: clubTeams,
      clubMembers: clubMembers,
      myTeamIds: myTeamIds,
      userId: userId,
    );
  }

  void _refresh() => setState(() => _future = _loadData());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: FutureBuilder<_ClubData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            final l10n = AppLocalizations.of(context)!;
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(l10n.homeLoadError,
                    style:
                        const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _refresh,
                  child: Text(l10n.homeRetry,
                      style: const TextStyle(color: AppColors.primary)),
                ),
              ]),
            );
          }
          final data = snapshot.data!;
          if (!data.hasClub) {
            return _NoClubView(onJoined: _refresh);
          }
          return _ClubView(data: data, onRefresh: _refresh);
        },
      ),
    );
  }
}

// ── No-club state ─────────────────────────────────────────────────────────

class _NoClubView extends StatelessWidget {
  final VoidCallback onJoined;
  const _NoClubView({required this.onJoined});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border:
                    Border.all(color: AppColors.uiBorder, width: 1.5),
              ),
              child: const Icon(Icons.domain_outlined,
                  size: 40, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.clubNoClub,
              style: GoogleFonts.exo2(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.clubNoClubSub,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDeep,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showClubList(context),
                child: Text(
                  l10n.clubFindClub,
                  style: GoogleFonts.exo2(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _createClub(context),
              icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
              label: Text(
                l10n.clubCreate,
                style: GoogleFonts.exo2(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createClub(BuildContext context) async {
    final saved = await showClubForm(context);
    if (saved == true) onJoined();
  }

  void _showClubList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ClubListSheet(onJoined: onJoined),
    );
  }
}

// ── Club list bottom sheet ────────────────────────────────────────────────

class _ClubListSheet extends StatefulWidget {
  final VoidCallback onJoined;
  const _ClubListSheet({required this.onJoined});

  @override
  State<_ClubListSheet> createState() => _ClubListSheetState();
}

class _ClubListSheetState extends State<_ClubListSheet> {
  final _clubHelper = ClubQueryHelper();
  final _userHelper = UserQueryHelper();
  late Future<List<Map<String, dynamic>>> _future;
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    _future = _clubHelper
        .getAllClubs(size: 50)
        .then((l) => l.cast<Map<String, dynamic>>());
  }

  Future<void> _join(BuildContext context, int clubId) async {
    setState(() => _joining = true);
    try {
      final user = await _userHelper.getMe();
      await _clubHelper.joinClub(clubId, user['id'] as int);
      if (context.mounted) Navigator.of(context).pop();
      widget.onJoined();
    } on DioException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.response?.data?['message'] ?? 'Erreur'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (ctx, scrollController) => Column(
        children: [
          _SheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Text(l10n.clubFindClub,
                style: GoogleFonts.exo2(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary));
                }
                if (snap.hasError || snap.data == null) {
                  return Center(
                      child: Text(l10n.homeLoadError,
                          style: const TextStyle(
                              color: AppColors.textSecondary)));
                }
                final clubs = snap.data!;
                return ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: clubs.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 8),
                  itemBuilder: (_, i) => _ClubListTile(
                    club: clubs[i],
                    joining: _joining,
                    onJoin: () => _join(context, clubs[i]['id'] as int),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: AppColors.uiBorder,
              borderRadius: BorderRadius.circular(2)),
        ),
      );
}

class _ClubListTile extends StatelessWidget {
  final Map<String, dynamic> club;
  final bool joining;
  final VoidCallback onJoin;
  const _ClubListTile(
      {required this.club, required this.joining, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.uiBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(club['name'] as String? ?? '',
                    style: GoogleFonts.exo2(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 15)),
                const SizedBox(height: 2),
                Text(club['city'] as String? ?? '',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.backgroundDeep,
              minimumSize: const Size(90, 36),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: joining ? null : onJoin,
            child: Text(l10n.teamsJoin,
                style: GoogleFonts.exo2(
                    fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── Has-club view ─────────────────────────────────────────────────────────

class _ClubView extends StatelessWidget {
  final _ClubData data;
  final VoidCallback onRefresh;
  const _ClubView({required this.data, required this.onRefresh});

  Future<void> _editClub(BuildContext context, Map<String, dynamic> club) async {
    final saved = await showClubForm(context, existing: club);
    if (saved == true) onRefresh();
  }

  Future<void> _deleteClub(
      BuildContext context, Map<String, dynamic> club) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.clubDeleteConfirm,
            style: GoogleFonts.exo2(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text(l10n.clubDeleteConfirmMessage(club['name'] as String? ?? ''),
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
            child: Text(l10n.clubDelete,
                style: GoogleFonts.exo2(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ClubQueryHelper().deleteClub(club['id'] as int);
      onRefresh();
    } on DioException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.response?.data?['message'] ?? 'Erreur'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  Future<void> _createTeam(BuildContext context, int clubId) async {
    final saved = await showTeamForm(context, clubId: clubId);
    if (saved == true) onRefresh();
  }

  Future<void> _addClubMember(BuildContext context, int clubId) async {
    final l10n = AppLocalizations.of(context)!;
    final existing = data.clubMembers
        .map((m) => (m['userId'] as num).toInt())
        .toSet();
    final userId = await showAddMemberSheet(context, excludeUserIds: existing);
    if (userId == null || !context.mounted) return;
    try {
      await ClubQueryHelper().joinClub(clubId, userId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.memberAdded),
          backgroundColor: AppColors.win,
        ));
      }
      onRefresh();
    } on DioException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.response?.data?['message'] ?? l10n.errorGeneric),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final club = data.clubDetails!;
    final members = data.clubMembers;
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
          children: [
            _SectionHeader(title: l10n.clubMyClub),
            const SizedBox(height: 12),
            _ClubHeader(
              club: club,
              canManage: data.canManage,
              onEdit: () => _editClub(context, club),
              onDelete: () => _deleteClub(context, club),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: _SectionHeader(title: l10n.clubTeams)),
              if (data.canManage)
                _AddButton(
                  label: l10n.teamCreate,
                  onTap: () => _createTeam(context, club['id'] as int),
                ),
            ]),
            const SizedBox(height: 12),
            if (data.clubTeams.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.teamsNoMyTeams,
                    style: const TextStyle(color: AppColors.textSecondary)),
              )
            else
              ...(List.of(data.clubTeams)
                    ..sort((a, b) {
                      final aMember = data.myTeamIds.contains((a['id'] as num).toInt()) ? 0 : 1;
                      final bMember = data.myTeamIds.contains((b['id'] as num).toInt()) ? 0 : 1;
                      return aMember.compareTo(bMember);
                    }))
                  .map((team) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ClubTeamTile(
                      team: team,
                      isMember: data.myTeamIds.contains((team['id'] as num).toInt()),
                      userId: data.userId,
                      onRefresh: onRefresh,
                    ),
                  )),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                  child: _SectionHeader(
                      title: '${l10n.clubMembers} (${members.length})')),
              if (data.canManage)
                _AddButton(
                  label: l10n.memberAdd,
                  onTap: () => _addClubMember(context, club['id'] as int),
                ),
            ]),
            const SizedBox(height: 12),
            if (members.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.clubNoMembers,
                    style: const TextStyle(color: AppColors.textSecondary)),
              )
            else
              ...members.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ClubMemberTile(
                      member: m,
                      clubId: club['id'] as int,
                      canManage: data.canManage,
                      isMe: (m['userId'] as num).toInt() == data.userId,
                      onRefresh: onRefresh,
                    ),
                  )),
          ],
        ),
        Positioned(
          bottom: 12,
          right: 16,
          child: _LeaveClubButton(
            clubId: club['id'] as int,
            userId: data.userId,
            onLeft: onRefresh,
          ),
        ),
      ],
    );
  }
}

class _ClubHeader extends StatelessWidget {
  final Map<String, dynamic> club;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ClubHeader({
    required this.club,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final description = club['description'] as String?;
    final website = club['websiteUrl'] as String?;
    final createdAt = club['createdAt'] as String?;
    final year = createdAt != null ? createdAt.split('-')[0] : null;

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
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.uiBorder, width: 1.5),
                ),
                child: const Icon(Icons.domain, size: 28, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(club['name'] as String? ?? '',
                        style: GoogleFonts.exo2(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.place_outlined,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(club['city'] as String? ?? '',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                      if (year != null) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(l10n.clubFounded(year),
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ]),
                  ],
                ),
              ),
              if (canManage) ...[
                IconButton(
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.edit_outlined,
                      size: 20, color: AppColors.textSecondary),
                ),
                IconButton(
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: AppColors.error),
                ),
              ],
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(color: AppColors.uiBorder, height: 1),
            const SizedBox(height: 12),
            Text(description,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5)),
          ],
          if (website != null && website.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.language_outlined,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(l10n.clubWebsite,
                  style: const TextStyle(
                      color: AppColors.primary, fontSize: 13)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(website,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

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

class _ClubTeamTile extends StatefulWidget {
  final Map<String, dynamic> team;
  final bool isMember;
  final int userId;
  final VoidCallback onRefresh;
  const _ClubTeamTile(
      {required this.team,
      required this.isMember,
      required this.userId,
      required this.onRefresh});

  @override
  State<_ClubTeamTile> createState() => _ClubTeamTileState();
}

class _ClubTeamTileState extends State<_ClubTeamTile> {
  final _teamHelper = TeamQueryHelper();
  bool _loading = false;

  Future<void> _join(BuildContext context) async {
    setState(() => _loading = true);
    try {
      await _teamHelper.addMember(
          widget.team['id'] as int, widget.userId);
      widget.onRefresh();
    } on DioException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.response?.data?['message'] ?? 'Erreur'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final team = widget.team;
    return GestureDetector(
      onTap: () async {
        final changed = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => TeamDetailScreen(
                teamId: (team['id'] as num).toInt(),
                initialName: team['name'] as String?),
          ),
        );
        if (changed == true) widget.onRefresh();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.uiBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(team['name'] as String? ?? '',
                    style: GoogleFonts.exo2(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Row(children: [
                  _Badge(label: team['category'] as String? ?? ''),
                  const SizedBox(width: 6),
                  _Badge(label: team['gender'] as String? ?? ''),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (_loading)
            const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2))
          else if (widget.isMember)
            _MemberChip(label: l10n.member)
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDeep,
                minimumSize: const Size(90, 36),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () => _join(context),
              child: Text(l10n.teamsJoin,
                  style: GoogleFonts.exo2(
                      fontWeight: FontWeight.w700, fontSize: 13)),
            ),
        ],
      ),
      ),
    );
  }
}

class _LeaveClubButton extends StatefulWidget {
  final int clubId;
  final int userId;
  final VoidCallback onLeft;
  const _LeaveClubButton(
      {required this.clubId,
      required this.userId,
      required this.onLeft});

  @override
  State<_LeaveClubButton> createState() => _LeaveClubButtonState();
}

class _LeaveClubButtonState extends State<_LeaveClubButton> {
  final _clubHelper = ClubQueryHelper();
  bool _loading = false;

  Future<void> _leave(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.clubLeaveConfirm,
            style: GoogleFonts.exo2(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        content: Text(l10n.clubLeaveConfirmMessage,
            style:
                const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel,
                style: const TextStyle(
                    color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.clubLeave,
                style: GoogleFonts.exo2(
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      await _clubHelper.leaveClub(widget.clubId, widget.userId);
      widget.onLeft();
    } on DioException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.response?.data?['message'] ?? 'Erreur'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: _loading ? null : () => _leave(context),
      icon: _loading
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  color: AppColors.textSecondary, strokeWidth: 1.5))
          : const Icon(Icons.logout, size: 14),
      label: Text(l10n.clubLeave,
          style: const TextStyle(fontSize: 12)),
    );
  }
}

// ── Shared micro-widgets ──────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

String _roleLabel(AppLocalizations l10n, String? role) => switch (role) {
      'ADMIN' => l10n.roleAdmin,
      'MANAGER' => l10n.roleManager,
      _ => l10n.roleMember,
    };

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          visualDensity: VisualDensity.compact,
        ),
        icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
        label: Text(label,
            style: GoogleFonts.exo2(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.primary)),
      );
}

// ── Club member tile (with role management) ────────────────────────────────

class _ClubMemberTile extends StatefulWidget {
  final Map<String, dynamic> member;
  final int clubId;
  final bool canManage;
  final bool isMe;
  final VoidCallback onRefresh;
  const _ClubMemberTile({
    required this.member,
    required this.clubId,
    required this.canManage,
    required this.isMe,
    required this.onRefresh,
  });

  @override
  State<_ClubMemberTile> createState() => _ClubMemberTileState();
}

class _ClubMemberTileState extends State<_ClubMemberTile> {
  final _clubHelper = ClubQueryHelper();

  Future<void> _manage() async {
    final l10n = AppLocalizations.of(context)!;
    final userId = (widget.member['userId'] as num).toInt();
    final currentRole = widget.member['role'] as String?;
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
            Text(widget.member['username'] as String? ?? '',
                style: GoogleFonts.exo2(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 16)),
            const SizedBox(height: 8),
            for (final role in const ['MEMBER', 'MANAGER', 'ADMIN'])
              ListTile(
                leading: const Icon(Icons.shield_outlined,
                    color: AppColors.primary),
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
        await _clubHelper.leaveClub(widget.clubId, userId);
      } else if (action.startsWith('role:')) {
        await _clubHelper.updateMemberRole(
            widget.clubId, userId, action.split(':')[1]);
      }
      widget.onRefresh();
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.response?.data?['message'] ?? 'Erreur'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final username = widget.member['username'] as String? ?? '';
    final role = widget.member['role'] as String?;
    final tappable = widget.canManage && !widget.isMe;
    return GestureDetector(
      onTap: tappable ? _manage : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isMe
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
              child: Text(username,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 15)),
            ),
            const SizedBox(width: 8),
            _Badge(label: _roleLabel(l10n, role)),
            if (tappable) ...[
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

class _MemberChip extends StatelessWidget {
  final String label;
  const _MemberChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.win.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: AppColors.win.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check, size: 14, color: AppColors.win),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: AppColors.win,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ]),
      );
}
