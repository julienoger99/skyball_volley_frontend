import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/helpers/team_query_helper.dart';
import '../../data/helpers/user_query_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../team_detail_screen.dart';

// ── Data ──────────────────────────────────────────────────────────────────

class _TeamsData {
  final int userId;
  final List<Map<String, dynamic>> myTeams;
  final List<Map<String, dynamic>> allTeams;
  final Set<int> myTeamIds;
  final int? userClubId;

  _TeamsData({
    required this.userId,
    required this.myTeams,
    required this.allTeams,
    required this.myTeamIds,
    required this.userClubId,
  });
}

// ── Tab root ──────────────────────────────────────────────────────────────

class TeamsTab extends StatefulWidget {
  const TeamsTab({super.key});

  @override
  State<TeamsTab> createState() => _TeamsTabState();
}

class _TeamsTabState extends State<TeamsTab> {
  final _userHelper = UserQueryHelper();
  final _teamHelper = TeamQueryHelper();
  late Future<_TeamsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_TeamsData> _loadData() async {
    final user = await _userHelper.getMe();
    final userId = user['id'] as int;

    final clubMemberships = (user['clubMemberships'] as List?) ?? [];
    final userClubId = clubMemberships.isNotEmpty
        ? clubMemberships[0]['clubId'] as int?
        : null;

    final teamMemberships = (user['teamMemberships'] as List?) ?? [];
    final myTeamIds =
        teamMemberships.map((m) => m['teamId'] as int).toSet();

    final myTeams = await Future.wait(
      myTeamIds.map((id) => _teamHelper.getTeamById(id)),
    );

    final allTeams = (await _teamHelper.getAllTeams(size: 50))
        .cast<Map<String, dynamic>>();

    return _TeamsData(
      userId: userId,
      myTeams: myTeams,
      allTeams: allTeams,
      myTeamIds: myTeamIds,
      userClubId: userClubId,
    );
  }

  void _refresh() => setState(() => _future = _loadData());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: FutureBuilder<_TeamsData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary));
          }
          if (snapshot.hasError) {
            final l10n = AppLocalizations.of(context)!;
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(l10n.teamsLoadError,
                    style: const TextStyle(
                        color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _refresh,
                  child: Text(l10n.homeRetry,
                      style: const TextStyle(
                          color: AppColors.primary)),
                ),
              ]),
            );
          }
          return _TeamsBody(
              data: snapshot.data!, onRefresh: _refresh);
        },
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────

class _TeamsBody extends StatelessWidget {
  final _TeamsData data;
  final VoidCallback onRefresh;
  const _TeamsBody({required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exploreTeams =
        data.allTeams.where((t) => !data.myTeamIds.contains(t['id'] as int)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: [
        _SectionHeader(title: l10n.teamsMyTeams),
        const SizedBox(height: 12),
        if (data.myTeams.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _EmptyCard(message: l10n.teamsNoMyTeams),
          )
        else
          ...data.myTeams.map((team) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MyTeamTile(
                    team: team,
                    userId: data.userId,
                    onRefresh: onRefresh),
              )),
        const SizedBox(height: 24),
        _SectionHeader(title: l10n.teamsExplore),
        const SizedBox(height: 12),
        if (exploreTeams.isEmpty)
          _EmptyCard(message: l10n.teamsNoMyTeams)
        else
          ...exploreTeams.map((team) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ExploreTeamTile(
                    team: team, data: data, onRefresh: onRefresh),
              )),
      ],
    );
  }
}

// ── My team tile (with leave) ─────────────────────────────────────────────

class _MyTeamTile extends StatefulWidget {
  final Map<String, dynamic> team;
  final int userId;
  final VoidCallback onRefresh;
  const _MyTeamTile(
      {required this.team,
      required this.userId,
      required this.onRefresh});

  @override
  State<_MyTeamTile> createState() => _MyTeamTileState();
}

class _MyTeamTileState extends State<_MyTeamTile> {
  final _teamHelper = TeamQueryHelper();
  bool _loading = false;

  Future<void> _leave(BuildContext context) async {
    setState(() => _loading = true);
    try {
      await _teamHelper.removeMember(
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
    final clubName = team['clubName'] as String?;
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
        border: Border.all(
            color: AppColors.teamHighlight.withValues(alpha: 0.35),
            width: 1),
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
                  _Badge(
                      label: team['category'] as String? ?? ''),
                  const SizedBox(width: 6),
                  _Badge(label: team['gender'] as String? ?? ''),
                  if (clubName != null) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.domain,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(clubName,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
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
          else
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(
                    color: AppColors.error, width: 1),
                minimumSize: const Size(80, 34),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () => _leave(context),
              child: Text(l10n.teamsLeave,
                  style: GoogleFonts.exo2(
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
        ],
      ),
      ),
    );
  }
}

// ── Explore team tile (with join) ─────────────────────────────────────────

class _ExploreTeamTile extends StatefulWidget {
  final Map<String, dynamic> team;
  final _TeamsData data;
  final VoidCallback onRefresh;
  const _ExploreTeamTile(
      {required this.team, required this.data, required this.onRefresh});

  @override
  State<_ExploreTeamTile> createState() => _ExploreTeamTileState();
}

class _ExploreTeamTileState extends State<_ExploreTeamTile> {
  final _teamHelper = TeamQueryHelper();
  bool _loading = false;

  Future<void> _tryJoin(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final team = widget.team;
    final teamClubId = team['clubId'] as int?;
    final teamClubName = team['clubName'] as String?;
    final userClubId = widget.data.userClubId;

    if (teamClubId != null &&
        userClubId != null &&
        userClubId != teamClubId) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.teamsDifferentClub),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    if (teamClubId != null &&
        userClubId == null &&
        teamClubName != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(l10n.clubAutoJoinTitle(teamClubName),
              style: GoogleFonts.exo2(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          content: Text(l10n.clubAutoJoinMessage(teamClubName),
              style: const TextStyle(
                  color: AppColors.textSecondary, height: 1.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel,
                  style: const TextStyle(
                      color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.backgroundDeep),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.confirm,
                  style: GoogleFonts.exo2(
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _loading = true);
    try {
      await _teamHelper.addMember(
          team['id'] as int, widget.data.userId);
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
    final clubName = team['clubName'] as String?;
    return Container(
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
                  _Badge(
                      label: team['category'] as String? ?? ''),
                  const SizedBox(width: 6),
                  _Badge(label: team['gender'] as String? ?? ''),
                  if (clubName != null) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.domain,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(clubName,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
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
              onPressed: () => _tryJoin(context),
              child: Text(l10n.teamsJoin,
                  style: GoogleFonts.exo2(
                      fontWeight: FontWeight.w700, fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

// ── Shared micro-widgets ──────────────────────────────────────────────────

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

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.uiBorder, width: 1),
        ),
        child: Text(message,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14)),
      );
}

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
