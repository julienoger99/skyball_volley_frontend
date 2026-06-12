import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/helpers/championship_query_helper.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Catégories de championnat (enum backend `CreateChampionshipDto.category`).
const championshipCategories = [
  'M7', 'M9', 'M11', 'M13', 'M15', 'M18', 'M21', 'SENIOR', 'MASTER', 'LOISIR',
];

/// Affiche le bottom sheet de création/édition d'un championnat.
/// Si [existing] est fourni, on édite (PUT) ; sinon on crée (POST).
/// Renvoie `true` si l'enregistrement a réussi.
Future<bool?> showChampionshipForm(
  BuildContext context, {
  Map<String, dynamic>? existing,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ChampionshipFormSheet(existing: existing),
  );
}

class _ChampionshipFormSheet extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const _ChampionshipFormSheet({this.existing});

  @override
  State<_ChampionshipFormSheet> createState() => _ChampionshipFormSheetState();
}

class _ChampionshipFormSheetState extends State<_ChampionshipFormSheet> {
  final _helper = ChampionshipQueryHelper();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _season;
  String? _category;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?['name'] as String? ?? '');
    _season =
        TextEditingController(text: widget.existing?['season'] as String? ?? '');
    final cat = widget.existing?['category'] as String?;
    if (cat != null && championshipCategories.contains(cat)) _category = cat;
  }

  @override
  void dispose() {
    _name.dispose();
    _season.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await _helper.updateChampionship(
          widget.existing!['id'] as int,
          name: _name.text.trim(),
          season: _season.text.trim(),
          category: _category,
        );
      } else {
        await _helper.createChampionship(
          name: _name.text.trim(),
          season: _season.text.trim(),
          category: _category,
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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEdit ? l10n.champEdit : l10n.champNew,
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
                    decoration: InputDecoration(labelText: l10n.champName),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _season,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(labelText: l10n.champSeason),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceHigh,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(labelText: l10n.champCategory),
                    items: championshipCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.of(context).pop(false),
                          child: Text(
                            l10n.cancel,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
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
