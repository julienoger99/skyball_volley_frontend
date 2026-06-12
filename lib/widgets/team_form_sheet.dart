import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/helpers/team_query_helper.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'championship_form_sheet.dart' show championshipCategories;

/// Genres d'équipe (enum backend `CreateTeamDto.gender`).
const teamGenders = ['MALE', 'FEMALE', 'MIXED'];

/// Affiche le bottom sheet de création/édition d'une équipe.
/// - Création : fournir [clubId] (l'équipe est rattachée à ce club).
/// - Édition : fournir [existing] (l'équipe). Renvoie `true` si enregistré.
Future<bool?> showTeamForm(
  BuildContext context, {
  Map<String, dynamic>? existing,
  int? clubId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _TeamFormSheet(existing: existing, clubId: clubId),
  );
}

class _TeamFormSheet extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final int? clubId;
  const _TeamFormSheet({this.existing, this.clubId});

  @override
  State<_TeamFormSheet> createState() => _TeamFormSheetState();
}

class _TeamFormSheetState extends State<_TeamFormSheet> {
  final _helper = TeamQueryHelper();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _logoUrl;
  String? _category;
  String? _gender;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?['name'] as String? ?? '');
    _logoUrl = TextEditingController(text: e?['logoUrl'] as String? ?? '');
    final cat = e?['category'] as String?;
    if (cat != null && championshipCategories.contains(cat)) _category = cat;
    final gender = e?['gender'] as String?;
    if (gender != null && teamGenders.contains(gender)) _gender = gender;
  }

  @override
  void dispose() {
    _name.dispose();
    _logoUrl.dispose();
    super.dispose();
  }

  String? _orNull(String s) => s.trim().isEmpty ? null : s.trim();

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_category == null || _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.fieldRequired),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await _helper.updateTeam(
          widget.existing!['id'] as int,
          name: _name.text.trim(),
          category: _category,
          gender: _gender,
          logoUrl: _orNull(_logoUrl.text),
        );
      } else {
        await _helper.createTeam(
          name: _name.text.trim(),
          category: _category!,
          gender: _gender!,
          clubId: widget.clubId,
          logoUrl: _orNull(_logoUrl.text),
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
                    Text(
                      _isEdit ? l10n.teamEdit : l10n.teamCreate,
                      style: GoogleFonts.exo2(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _name,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(labelText: l10n.teamName),
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.fieldRequired
                          : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceHigh,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(labelText: l10n.teamCategory),
                      items: championshipCategories
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _category = v),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceHigh,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(labelText: l10n.teamGenderLabel),
                      items: teamGenders
                          .map((g) =>
                              DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _logoUrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(labelText: l10n.teamLogoUrl),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
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
                      ],
                    ),
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
