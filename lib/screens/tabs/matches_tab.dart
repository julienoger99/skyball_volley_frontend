import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/helpers/championship_query_helper.dart';
import '../../data/helpers/match_query_helper.dart';
import '../../data/helpers/user_query_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/championship_form_sheet.dart';
import '../../widgets/match_card.dart';
import '../../widgets/match_form_sheet.dart';
import '../championship_detail_screen.dart';
import '../match_detail_screen.dart';

// ── Data ──────────────────────────────────────────────────────────────────

enum _MatchesView { myMatches, championships }

class _MatchesData {
  final bool hasTeams;
  final List<Map<String, dynamic>> upcoming;
  final List<Map<String, dynamic>> played;
  final List<Map<String, dynamic>> managedTeams;

  _MatchesData({
    required this.hasTeams,
    required this.upcoming,
    required this.played,
    required this.managedTeams,
  });
}

const _managerRoles = {'MANAGER', 'ADMIN'};

// ── Tab root ──────────────────────────────────────────────────────────────

class MatchesTab extends StatefulWidget {
  const MatchesTab({super.key});

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  final _userHelper = UserQueryHelper();
  final _matchHelper = MatchQueryHelper();
  late Future<_MatchesData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_MatchesData> _loadData() async {
    final user = await _userHelper.getMe();
    final memberships =
        ((user['teamMemberships'] as List?) ?? []).cast<Map<String, dynamic>>();
    final managedTeams = memberships
        .where((m) => _managerRoles.contains(m['role'] as String?))
        .toList();
    if (memberships.isEmpty) {
      return _MatchesData(
          hasTeams: false, upcoming: [], played: [], managedTeams: managedTeams);
    }

    final allMatches = <Map<String, dynamic>>[];
    for (final m in memberships) {
      final teamId = (m['teamId'] as num).toInt();
      final matches = await _matchHelper.getMatchesByTeam(teamId, size: 100);
      allMatches.addAll(matches.cast<Map<String, dynamic>>());
    }

    final now = DateTime.now();
    final upcoming = allMatches
        .where((m) =>
            m['status'] == 'SCHEDULED' &&
            DateTime.parse(m['matchDate']).isAfter(now))
        .toList()
      ..sort((a, b) => DateTime.parse(a['matchDate'])
          .compareTo(DateTime.parse(b['matchDate'])));

    final played = allMatches.where((m) => m['status'] == 'PLAYED').toList()
      ..sort((a, b) => DateTime.parse(b['matchDate'])
          .compareTo(DateTime.parse(a['matchDate'])));

    return _MatchesData(
        hasTeams: true,
        upcoming: upcoming,
        played: played,
        managedTeams: managedTeams);
  }

  void _refresh() => setState(() => _future = _loadData());

  _MatchesView _view = _MatchesView.myMatches;

  Future<void> _openMatch(int matchId) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MatchDetailScreen(matchId: matchId),
      ),
    );
    if (changed == true) _refresh();
  }

  Future<void> _createMatch(List<Map<String, dynamic>> managedTeams) async {
    final saved = await showMatchForm(context, managedTeams: managedTeams);
    if (saved == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: _ViewToggle(
                view: _view,
                onChanged: (v) => setState(() => _view = v),
              ),
            ),
            Expanded(
              child: _view == _MatchesView.myMatches
                  ? _buildMyMatches(context, l10n)
                  : const _ChampionshipsView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyMatches(BuildContext context, AppLocalizations l10n) {
    return FutureBuilder<_MatchesData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(l10n.matchesLoadError,
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
          return Stack(
            children: [
              RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceHigh,
                onRefresh: () async => _refresh(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
                  children: [
                    _SectionHeader(text: l10n.matchesUpcoming),
                    const SizedBox(height: 12),
                    if (!data.hasTeams)
                      _EmptyCard(message: l10n.homeNoTeam)
                    else if (data.upcoming.isEmpty)
                      _EmptyCard(message: l10n.matchesNoUpcoming)
                    else
                      ...data.upcoming.map((m) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: MatchCard(
                              match: m,
                              onTap: () => _openMatch((m['id'] as num).toInt()),
                            ),
                          )),
                    const SizedBox(height: 32),
                    _SectionHeader(text: l10n.matchesResults),
                    const SizedBox(height: 12),
                    if (!data.hasTeams || data.played.isEmpty)
                      _EmptyCard(message: l10n.matchesNoResults)
                    else
                      ...data.played.map((m) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: MatchCard(
                              match: m,
                              onTap: () => _openMatch((m['id'] as num).toInt()),
                            ),
                          )),
                  ],
                ),
              ),
              if (data.managedTeams.isNotEmpty)
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: FloatingActionButton(
                    onPressed: () => _createMatch(data.managedTeams),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.backgroundDeep,
                    child: const Icon(Icons.add),
                  ),
                ),
            ],
          );
        },
      );
  }
}

// ── View toggle ───────────────────────────────────────────────────────────

class _ViewToggle extends StatelessWidget {
  final _MatchesView view;
  final ValueChanged<_MatchesView> onChanged;
  const _ViewToggle({required this.view, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.uiBorder, width: 1),
      ),
      child: Row(
        children: [
          _ToggleSegment(
            label: l10n.matchesMyMatches,
            selected: view == _MatchesView.myMatches,
            onTap: () => onChanged(_MatchesView.myMatches),
          ),
          _ToggleSegment(
            label: l10n.matchesChampionships,
            selected: view == _MatchesView.championships,
            onTap: () => onChanged(_MatchesView.championships),
          ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleSegment(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.exo2(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.backgroundDeep : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Championships view ────────────────────────────────────────────────────

class _ChampionshipsView extends StatefulWidget {
  const _ChampionshipsView();

  @override
  State<_ChampionshipsView> createState() => _ChampionshipsViewState();
}

class _ChampionshipsViewState extends State<_ChampionshipsView> {
  final _champHelper = ChampionshipQueryHelper();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() => _champHelper
      .getAllChampionships(size: 50)
      .then((l) => l.cast<Map<String, dynamic>>());

  void _refresh() => setState(() => _future = _load());

  Future<void> _create() async {
    final saved = await showChampionshipForm(context);
    if (saved == true) _refresh();
  }

  Future<void> _openDetail(Map<String, dynamic> champ) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChampionshipDetailScreen(
          championshipId: champ['id'] as int,
          initialName: champ['name'] as String?,
        ),
      ),
    );
    if (changed == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      children: [
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(l10n.champLoadError,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _refresh,
                    child: Text(l10n.homeRetry,
                        style: const TextStyle(color: AppColors.primary)),
                  ),
                ]),
              );
            }
            final champs = snapshot.data!;
            if (champs.isEmpty) {
              return Center(
                child: Text(l10n.champNoChampionships,
                    style: const TextStyle(color: AppColors.textSecondary)),
              );
            }
            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceHigh,
              onRefresh: () async => _refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                itemCount: champs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _ChampionshipCard(
                  championship: champs[i],
                  onTap: () => _openDetail(champs[i]),
                ),
              ),
            );
          },
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            onPressed: _create,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.backgroundDeep,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _ChampionshipCard extends StatelessWidget {
  final Map<String, dynamic> championship;
  final VoidCallback onTap;
  const _ChampionshipCard(
      {required this.championship, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final season = championship['season'] as String?;
    final category = championship['category'] as String?;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.uiBorder, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceHigh,
                border: Border.all(color: AppColors.uiBorder, width: 1),
              ),
              child: const Icon(Icons.emoji_events,
                  size: 22, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(championship['name'] as String? ?? '',
                      style: GoogleFonts.exo2(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(children: [
                    if (season != null && season.isNotEmpty)
                      Text(season,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    if (category != null && category.isNotEmpty) ...[
                      if (season != null && season.isNotEmpty)
                        const SizedBox(width: 8),
                      _Badge(label: category),
                    ],
                  ]),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

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

// ── Section header ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader({required this.text});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.exo2(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
}

// ── Empty card ────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.uiBorder, width: 1),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style:
              const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      );
}
