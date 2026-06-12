import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/helpers/championship_query_helper.dart';
import '../data/helpers/match_query_helper.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

const _matchStatuses = ['SCHEDULED', 'PLAYED', 'CANCELLED', 'POSTPONED', 'FORFEIT'];

/// Affiche le bottom sheet de création/édition d'un match.
/// - Création : fournir [managedTeams] (membreships où le user est MANAGER/ADMIN).
/// - Édition : fournir [existing] (le match). Renvoie `true` si enregistré.
Future<bool?> showMatchForm(
  BuildContext context, {
  Map<String, dynamic>? existing,
  List<Map<String, dynamic>>? managedTeams,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _MatchFormSheet(
      existing: existing,
      managedTeams: managedTeams ?? const [],
    ),
  );
}

class _MatchFormSheet extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final List<Map<String, dynamic>> managedTeams;
  const _MatchFormSheet({this.existing, required this.managedTeams});

  @override
  State<_MatchFormSheet> createState() => _MatchFormSheetState();
}

class _MatchFormSheetState extends State<_MatchFormSheet> {
  final _matchHelper = MatchQueryHelper();
  final _champHelper = ChampionshipQueryHelper();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _opponent;
  late final TextEditingController _location;
  late final TextEditingController _coachMessage;

  int? _teamId;
  DateTime? _date;
  bool _home = true;
  int? _championshipId;
  String _status = 'SCHEDULED';
  String? _forfeitedBy;
  bool _saving = false;

  List<Map<String, dynamic>> _championships = [];
  bool _loadingChamps = true;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _opponent = TextEditingController();
    _location = TextEditingController(text: e?['location'] as String? ?? '');
    _coachMessage =
        TextEditingController(text: e?['coachMessage'] as String? ?? '');
    if (e != null) {
      _date = DateTime.tryParse(e['matchDate'] as String? ?? '');
      _home = e['home'] == true;
      _championshipId = (e['championship']?['id'] as num?)?.toInt();
      _status = e['status'] as String? ?? 'SCHEDULED';
      _forfeitedBy = e['forfeitedBy'] as String?;
    } else if (widget.managedTeams.length == 1) {
      _teamId = (widget.managedTeams.first['teamId'] as num).toInt();
    }
    _loadChampionships();
  }

  Future<void> _loadChampionships() async {
    try {
      final list = await _champHelper.getAllChampionships(size: 50);
      if (mounted) {
        setState(() {
          _championships = list.cast<Map<String, dynamic>>();
          _loadingChamps = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingChamps = false);
    }
  }

  @override
  void dispose() {
    _opponent.dispose();
    _location.dispose();
    _coachMessage.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final base = _date ?? now;
    final day = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (!mounted) return;
    setState(() {
      _date = DateTime(day.year, day.month, day.day, time?.hour ?? 0,
          time?.minute ?? 0);
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.matchDateRequired),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    if (!_isEdit && _teamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.matchTeamRequired),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    setState(() => _saving = true);
    final isoDate = _date!.toIso8601String();
    try {
      if (_isEdit) {
        await _matchHelper.updateMatch(
          widget.existing!['id'] as int,
          matchDate: isoDate,
          location: _location.text.trim(),
          home: _home,
          championshipId: _championshipId,
          status: _status,
          forfeitedBy: _status == 'FORFEIT' ? _forfeitedBy : null,
          coachMessage: _coachMessage.text.trim(),
        );
      } else {
        await _matchHelper.createMatch(
          _teamId!,
          matchDate: isoDate,
          opponentName: _opponent.text.trim().isEmpty
              ? null
              : _opponent.text.trim(),
          location: _location.text.trim().isEmpty ? null : _location.text.trim(),
          home: _home,
          championshipId: _championshipId,
          coachMessage: _coachMessage.text.trim().isEmpty
              ? null
              : _coachMessage.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.response?.data?['message'] ?? 'Erreur'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isEdit ? l10n.matchEditTitle : l10n.matchCreate,
                        style: GoogleFonts.exo2(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 20),

                    // Team selector (create only)
                    if (!_isEdit) ...[
                      DropdownButtonFormField<int>(
                        initialValue: _teamId,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceHigh,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(labelText: l10n.matchTeam),
                        items: widget.managedTeams
                            .map((t) => DropdownMenuItem(
                                  value: (t['teamId'] as num).toInt(),
                                  child: Text(t['teamName'] as String? ?? ''),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _teamId = v),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _opponent,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration:
                            InputDecoration(labelText: l10n.matchOpponent),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Date
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: InputDecoration(labelText: l10n.matchDate),
                        child: Text(
                          _date == null
                              ? l10n.matchPickDate
                              : DateFormat('EEE d MMM yyyy • HH:mm', locale)
                                  .format(_date!),
                          style: TextStyle(
                              color: _date == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _location,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(labelText: l10n.matchLocation),
                    ),
                    const SizedBox(height: 14),

                    // Home / away
                    Row(children: [
                      Expanded(
                        child: Text(l10n.matchHome,
                            style:
                                const TextStyle(color: AppColors.textPrimary)),
                      ),
                      Switch(
                        value: _home,
                        activeThumbColor: AppColors.primary,
                        onChanged: (v) => setState(() => _home = v),
                      ),
                    ]),
                    const SizedBox(height: 6),

                    // Championship dropdown (optional)
                    if (_loadingChamps)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(
                            color: AppColors.primary,
                            backgroundColor: AppColors.surfaceHigh),
                      )
                    else
                      DropdownButtonFormField<int?>(
                        initialValue: _championshipId,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceHigh,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration:
                            InputDecoration(labelText: l10n.matchChampionship),
                        items: [
                          DropdownMenuItem<int?>(
                              value: null, child: Text(l10n.matchNoChampionship)),
                          ..._championships.map((c) => DropdownMenuItem<int?>(
                                value: (c['id'] as num).toInt(),
                                child: Text(c['name'] as String? ?? ''),
                              )),
                        ],
                        onChanged: (v) => setState(() => _championshipId = v),
                      ),
                    const SizedBox(height: 14),

                    // Status + forfeitedBy (edit only)
                    if (_isEdit) ...[
                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceHigh,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(labelText: l10n.matchStatus),
                        items: _matchStatuses
                            .map((s) => DropdownMenuItem(
                                value: s, child: Text(_statusLabel(l10n, s))))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _status = v ?? 'SCHEDULED'),
                      ),
                      if (_status == 'FORFEIT') ...[
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: _forfeitedBy,
                          isExpanded: true,
                          dropdownColor: AppColors.surfaceHigh,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration:
                              InputDecoration(labelText: l10n.matchForfeitedBy),
                          items: [
                            DropdownMenuItem(
                                value: 'HOME', child: Text(l10n.homeHome)),
                            DropdownMenuItem(
                                value: 'AWAY', child: Text(l10n.homeAway)),
                          ],
                          onChanged: (v) => setState(() => _forfeitedBy = v),
                        ),
                      ],
                      const SizedBox(height: 14),
                    ],

                    TextFormField(
                      controller: _coachMessage,
                      style: const TextStyle(color: AppColors.textPrimary),
                      maxLines: 3,
                      decoration:
                          InputDecoration(labelText: l10n.matchCoachMessage),
                    ),
                    const SizedBox(height: 24),

                    Row(children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.of(context).pop(false),
                          child: Text(l10n.cancel,
                              style: const TextStyle(
                                  color: AppColors.textSecondary)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: AppColors.backgroundDeep,
                                      strokeWidth: 2),
                                )
                              : Text(l10n.champSave),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _statusLabel(AppLocalizations l10n, String s) => switch (s) {
      'PLAYED' => l10n.matchStatusPlayed,
      'CANCELLED' => l10n.matchStatusCancelled,
      'POSTPONED' => l10n.matchStatusPostponed,
      'FORFEIT' => l10n.matchStatusForfeit,
      _ => l10n.matchStatusScheduled,
    };

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.uiBorder,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}
