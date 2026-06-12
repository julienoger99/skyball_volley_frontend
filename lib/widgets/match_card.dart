import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'matchup_title.dart';

/// Carte de match réutilisable. Choisit le rendu « à venir » (date/lieu) ou
/// « résultat » (score sets) selon `match['status']` (`PLAYED` = résultat).
class MatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final VoidCallback? onTap;
  const MatchCard({super.key, required this.match, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPlayed = match['status'] == 'PLAYED';
    final card = isPlayed ? _ResultCard(match: match) : _UpcomingCard(match: match);
    if (onTap == null) return card;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}

// ── Upcoming match card ───────────────────────────────────────────────────

class _UpcomingCard extends StatelessWidget {
  final Map<String, dynamic> match;
  const _UpcomingCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateTime.parse(match['matchDate']);
    final dateLabel =
        DateFormat('EEE d MMM • HH:mm', locale).format(date);
    final isHome = match['home'] == true;
    final location = match['location'] as String?;
    final championship = match['championship']?['name'] as String?;
    final venueIcon =
        isHome ? Icons.home_outlined : Icons.flight_takeoff;
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
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
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ),
                  ],
                ]),
                const SizedBox(height: 10),
                MatchupTitle(match: match, fontSize: 16),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.calendar_today,
                      size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(dateLabel,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ]),
                if (location != null && location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.place_outlined,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(location,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13)),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result card ───────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> match;
  const _ResultCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateTime.parse(match['matchDate']);
    final dateLabel = DateFormat('d MMM yyyy', locale).format(date);
    final championship = match['championship']?['name'] as String?;
    final teamSets = match['teamSetsWon'] ?? 0;
    final opponentSets = match['opponentSetsWon'] ?? 0;
    final isHome = match['home'] == true;
    final homeScore = isHome ? teamSets : opponentSets;
    final awayScore = isHome ? opponentSets : teamSets;

    Color scoreColor;
    if (teamSets == opponentSets) {
      scoreColor = AppColors.textSecondary;
    } else if (teamSets > opponentSets) {
      scoreColor = AppColors.win;
    } else {
      scoreColor = AppColors.error;
    }

    return Container(
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
                Row(children: [
                  Text(dateLabel,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  if (championship != null) ...[
                    const Text(' · ',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    Expanded(
                      child: Text(championship,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ),
                  ],
                ]),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: scoreColor.withValues(alpha: 0.4), width: 1),
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
    );
  }
}
