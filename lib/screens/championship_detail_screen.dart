import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/helpers/championship_query_helper.dart';
import '../data/helpers/match_query_helper.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/championship_form_sheet.dart';
import '../widgets/match_card.dart';
import 'match_detail_screen.dart';

// ── Data ──────────────────────────────────────────────────────────────────

class _ChampionshipData {
  final Map<String, dynamic> championship;
  final List<Map<String, dynamic>> matches;

  _ChampionshipData({required this.championship, required this.matches});
}

// ── Screen ────────────────────────────────────────────────────────────────

class ChampionshipDetailScreen extends StatefulWidget {
  final int championshipId;
  final String? initialName;

  const ChampionshipDetailScreen({
    super.key,
    required this.championshipId,
    this.initialName,
  });

  @override
  State<ChampionshipDetailScreen> createState() =>
      _ChampionshipDetailScreenState();
}

class _ChampionshipDetailScreenState extends State<ChampionshipDetailScreen> {
  final _champHelper = ChampionshipQueryHelper();
  final _matchHelper = MatchQueryHelper();
  late Future<_ChampionshipData> _future;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_ChampionshipData> _loadData() async {
    final championship =
        await _champHelper.getChampionshipById(widget.championshipId);
    final matches =
        (await _matchHelper.getMatchesByChampionship(widget.championshipId, size: 100))
            .cast<Map<String, dynamic>>()
      ..sort((a, b) => DateTime.parse(b['matchDate'])
          .compareTo(DateTime.parse(a['matchDate'])));
    return _ChampionshipData(championship: championship, matches: matches);
  }

  void _refresh() => setState(() => _future = _loadData());

  Future<void> _edit(Map<String, dynamic> championship) async {
    final saved = await showChampionshipForm(context, existing: championship);
    if (saved == true) {
      _changed = true;
      _refresh();
    }
  }

  Future<void> _delete(Map<String, dynamic> championship) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.champDeleteConfirm,
          style: GoogleFonts.exo2(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        content: Text(
          l10n.champDeleteConfirmMessage(championship['name'] as String? ?? ''),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child:
                Text(l10n.cancel, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.champDelete,
                style: GoogleFonts.exo2(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _champHelper.deleteChampionship(championship['id'] as int);
      if (mounted) Navigator.of(context).pop(true);
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: FutureBuilder<_ChampionshipData>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      _TopBar(
                          title: widget.initialName ?? '',
                          onBack: () => Navigator.of(context).pop(_changed)),
                      const Expanded(
                        child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary)),
                      ),
                    ],
                  );
                }
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      _TopBar(
                          title: widget.initialName ?? '',
                          onBack: () => Navigator.of(context).pop(_changed)),
                      Expanded(
                        child: Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(l10n.champLoadError,
                                style: const TextStyle(
                                    color: AppColors.textSecondary)),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _refresh,
                              child: Text(l10n.homeRetry,
                                  style:
                                      const TextStyle(color: AppColors.primary)),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  );
                }
                final data = snapshot.data!;
                final champ = data.championship;
                return Column(
                  children: [
                    _TopBar(
                      title: champ['name'] as String? ?? '',
                      onBack: () => Navigator.of(context).pop(_changed),
                      onEdit: () => _edit(champ),
                      onDelete: () => _delete(champ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                        children: [
                          _ChampionshipHeader(championship: champ),
                          const SizedBox(height: 24),
                          _SectionHeader(title: l10n.champMatches),
                          const SizedBox(height: 12),
                          if (data.matches.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(l10n.champNoMatches,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary)),
                            )
                          else
                            ...data.matches.map((m) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: MatchCard(
                                    match: m,
                                    onTap: () async {
                                      final changed =
                                          await Navigator.of(context).push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) => MatchDetailScreen(
                                              matchId: (m['id'] as num).toInt()),
                                        ),
                                      );
                                      if (changed == true) _refresh();
                                    },
                                  ),
                                )),
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
}

// ── Top bar ───────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _TopBar({
    required this.title,
    required this.onBack,
    this.onEdit,
    this.onDelete,
  });

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
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.exo2(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
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

class _ChampionshipHeader extends StatelessWidget {
  final Map<String, dynamic> championship;
  const _ChampionshipHeader({required this.championship});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final season = championship['season'] as String?;
    final category = championship['category'] as String?;

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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.uiBorder, width: 1.5),
            ),
            child:
                const Icon(Icons.emoji_events, size: 28, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(championship['name'] as String? ?? '',
                    style: GoogleFonts.exo2(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Row(children: [
                  if (season != null && season.isNotEmpty) ...[
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${l10n.champSeason}: $season',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                  if (category != null && category.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    _Badge(label: category),
                  ],
                ]),
              ],
            ),
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
