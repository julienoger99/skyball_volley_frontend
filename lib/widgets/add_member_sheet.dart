import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/helpers/user_query_helper.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Affiche un annuaire (getAllUsers) permettant à un manager de choisir un
/// utilisateur à ajouter à un club ou une équipe.
///
/// Les utilisateurs dont l'id est dans [excludeUserIds] (déjà membres) sont
/// masqués. Renvoie l'id de l'utilisateur choisi, ou `null` si annulé.
Future<int?> showAddMemberSheet(
  BuildContext context, {
  required Set<int> excludeUserIds,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AddMemberSheet(excludeUserIds: excludeUserIds),
  );
}

class _AddMemberSheet extends StatefulWidget {
  final Set<int> excludeUserIds;
  const _AddMemberSheet({required this.excludeUserIds});

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _userHelper = UserQueryHelper();
  late Future<List<dynamic>> _future;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _userHelper.getAllUsers();
    _searchController.addListener(
        () => setState(() => _query = _searchController.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const _SheetHandle(),
            const SizedBox(height: 12),
            Text(
              l10n.memberPickTitle,
              style: GoogleFonts.exo2(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.memberSearchHint,
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(l10n.homeLoadError,
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                    );
                  }
                  final users = snapshot.data!
                      .cast<Map<String, dynamic>>()
                      .where((u) => !widget.excludeUserIds
                          .contains((u['id'] as num).toInt()))
                      .where((u) {
                    if (_query.isEmpty) return true;
                    final name =
                        (u['username'] as String? ?? '').toLowerCase();
                    final email = (u['email'] as String? ?? '').toLowerCase();
                    return name.contains(_query) || email.contains(_query);
                  }).toList();

                  if (users.isEmpty) {
                    return Center(
                      child: Text(l10n.memberNoResults,
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: users.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final u = users[i];
                      return _UserTile(
                        username: u['username'] as String? ?? '?',
                        email: u['email'] as String? ?? '',
                        onTap: () =>
                            Navigator.of(context).pop((u['id'] as num).toInt()),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final String username;
  final String email;
  final VoidCallback onTap;
  const _UserTile(
      {required this.username, required this.email, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryDim,
                child: Text(
                  initial,
                  style: GoogleFonts.exo2(
                      color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                    if (email.isNotEmpty)
                      Text(email,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.add_circle_outline,
                  color: AppColors.primary, size: 22),
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
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.uiBorder,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}
