import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/helpers/match_query_helper.dart';
import '../../data/helpers/user_query_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/matchup_title.dart';

class _HomeData {
  final String username;
  final List<dynamic> teamMemberships;
  final Map<String, dynamic>? nextMatch;
  final List<Map<String, dynamic>> recentResults;

  _HomeData({
    required this.username,
    required this.teamMemberships,
    required this.nextMatch,
    required this.recentResults,
  });
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _userHelper = UserQueryHelper();
  final _matchHelper = MatchQueryHelper();
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_HomeData> _loadData() async {
    final user = await _userHelper.getMe();
    final memberships = (user['teamMemberships'] as List?) ?? [];

    final allMatches = <Map<String, dynamic>>[];
    for (final m in memberships) {
      final teamId = m['teamId'] as int;
      final matches = await _matchHelper.getMatchesByTeam(teamId);
      allMatches.addAll(matches.cast<Map<String, dynamic>>());
    }

    final now = DateTime.now();
    final upcoming = allMatches
        .where((m) =>
            m['status'] == 'SCHEDULED' && DateTime.parse(m['matchDate']).isAfter(now))
        .toList()
      ..sort((a, b) =>
          DateTime.parse(a['matchDate']).compareTo(DateTime.parse(b['matchDate'])));

    final played = allMatches.where((m) => m['status'] == 'PLAYED').toList()
      ..sort((a, b) =>
          DateTime.parse(b['matchDate']).compareTo(DateTime.parse(a['matchDate'])));

    return _HomeData(
      username: user['username'] as String,
      teamMemberships: memberships,
      nextMatch: upcoming.isNotEmpty ? upcoming.first : null,
      recentResults: played.take(3).toList(),
    );
  }

  void _refresh() => setState(() => _future = _loadData());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<_HomeData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return _ErrorView(message: l10n.homeLoadError, onRetry: _refresh);
        }
        final data = snapshot.data!;
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceHigh,
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _Greeting(username: data.username),
              const SizedBox(height: 32),
              _SectionHeader(text: l10n.homeNextMatch),
              const SizedBox(height: 12),
              if (data.teamMemberships.isEmpty)
                _EmptyCard(message: l10n.homeNoTeam)
              else if (data.nextMatch == null)
                _EmptyCard(message: l10n.homeNoUpcomingMatch)
              else
                _NextMatchCard(match: data.nextMatch!),
              const SizedBox(height: 32),
              _SectionHeader(text: l10n.homeRecentResults),
              const SizedBox(height: 12),
              if (data.recentResults.isEmpty)
                _EmptyCard(message: l10n.homeNoRecentResults)
              else
                ...data.recentResults.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ResultCard(match: m),
                    )),
            ],
          ),
        );
      },
    );
  }
}

class _Greeting extends StatelessWidget {
  final String username;
  const _Greeting({required this.username});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeGreeting(username),
          style: GoogleFonts.exo2(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

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

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.uiBorder, width: 1),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      );
}

class _NextMatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  const _NextMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateTime.parse(match['matchDate']);
    final dateLabel = DateFormat('EEEE d MMMM • HH:mm', locale).format(date);
    final isHome = match['home'] == true;
    final location = match['location'] as String?;
    final championship = match['championship']?['name'] as String?;
    final venueIcon = isHome ? Icons.home_outlined : Icons.flight_takeoff;
    final venueLabel = isHome ? l10n.homeHome : l10n.homeAway;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceHigh, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, Color(0xFFFFEA6A)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(venueIcon, color: AppColors.primary, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      venueLabel,
                      style: GoogleFonts.exo2(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (championship != null) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          championship,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                MatchupTitle(match: match, fontSize: 19),
                const SizedBox(height: 14),
                _InfoLine(icon: Icons.calendar_today, text: dateLabel),
                if (location != null && location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _InfoLine(icon: Icons.place_outlined, text: location),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 13),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      );
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> match;
  const _ResultCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateTime.parse(match['matchDate']);
    final dateLabel = DateFormat('d MMM', locale).format(date);
    final teamSets = match['teamSetsWon'] ?? 0;
    final opponentSets = match['opponentSetsWon'] ?? 0;
    Color scoreColor;
    if (teamSets == opponentSets) {
      scoreColor = AppColors.textSecondary;
    } else if (teamSets > opponentSets) {
      scoreColor = AppColors.win;
    } else {
      scoreColor = AppColors.error;
    }

    final isHome = match['home'] == true;
    final homeScore = isHome ? teamSets : opponentSets;
    final awayScore = isHome ? opponentSets : teamSets;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.uiBorder, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MatchupTitle(match: match, fontSize: 14),
                  const SizedBox(height: 4),
                  Text(
                    dateLabel,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scoreColor.withValues(alpha: 0.4), width: 1),
              ),
              child: Text(
                '$homeScore – $awayScore',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 36),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
            child: Text(l10n.homeRetry),
          ),
        ],
      ),
    );
  }
}
