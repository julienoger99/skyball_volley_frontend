import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/helpers/club_query_helper.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Affiche le bottom sheet de création/édition d'un club.
/// Si [existing] est fourni, on édite (PUT) ; sinon on crée (POST).
/// Renvoie `true` si l'enregistrement a réussi.
Future<bool?> showClubForm(
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
    builder: (_) => _ClubFormSheet(existing: existing),
  );
}

class _ClubFormSheet extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const _ClubFormSheet({this.existing});

  @override
  State<_ClubFormSheet> createState() => _ClubFormSheetState();
}

class _ClubFormSheetState extends State<_ClubFormSheet> {
  final _helper = ClubQueryHelper();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _city;
  late final TextEditingController _description;
  late final TextEditingController _websiteUrl;
  late final TextEditingController _logoUrl;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?['name'] as String? ?? '');
    _city = TextEditingController(text: e?['city'] as String? ?? '');
    _description =
        TextEditingController(text: e?['description'] as String? ?? '');
    _websiteUrl = TextEditingController(text: e?['websiteUrl'] as String? ?? '');
    _logoUrl = TextEditingController(text: e?['logoUrl'] as String? ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _description.dispose();
    _websiteUrl.dispose();
    _logoUrl.dispose();
    super.dispose();
  }

  String? _orNull(String s) => s.trim().isEmpty ? null : s.trim();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await _helper.updateClub(
          widget.existing!['id'] as int,
          name: _name.text.trim(),
          city: _city.text.trim(),
          description: _orNull(_description.text),
          websiteUrl: _orNull(_websiteUrl.text),
          logoUrl: _orNull(_logoUrl.text),
        );
      } else {
        await _helper.createClub(
          name: _name.text.trim(),
          city: _city.text.trim(),
          description: _orNull(_description.text),
          websiteUrl: _orNull(_websiteUrl.text),
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
                      _isEdit ? l10n.clubEdit : l10n.clubCreate,
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
                      decoration: InputDecoration(labelText: l10n.clubName),
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.fieldRequired
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _city,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(labelText: l10n.clubCity),
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.fieldRequired
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _description,
                      style: const TextStyle(color: AppColors.textPrimary),
                      maxLines: 3,
                      decoration:
                          InputDecoration(labelText: l10n.clubDescription),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _websiteUrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.url,
                      decoration:
                          InputDecoration(labelText: l10n.clubWebsiteUrl),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _logoUrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(labelText: l10n.clubLogoUrl),
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
