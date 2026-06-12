import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/language_switcher.dart';
import 'tabs/home_tab.dart';
import 'tabs/matches_tab.dart';
import 'tabs/teams_tab.dart';
import 'tabs/club_tab.dart';
import 'tabs/profile_tab.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;
  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _index = widget.initialIndex;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const HomeTab(),
      const MatchesTab(),
      const TeamsTab(),
      const ClubTab(),
      ProfileTab(onNavigate: (i) => setState(() => _index = i)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(
                color: AppColors.uiBorder.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primary, Color(0xFFFFEA6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      'SKYBALL',
                      style: GoogleFonts.exo2(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const LanguageSwitcher(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.uiBorder.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryDim,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined, color: AppColors.textSecondary),
              selectedIcon: const Icon(Icons.home, color: AppColors.primary),
              label: l10n.tabHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.sports_volleyball_outlined, color: AppColors.textSecondary),
              selectedIcon: const Icon(Icons.sports_volleyball, color: AppColors.primary),
              label: l10n.tabMatches,
            ),
            NavigationDestination(
              icon: const Icon(Icons.groups_outlined, color: AppColors.textSecondary),
              selectedIcon: const Icon(Icons.groups, color: AppColors.primary),
              label: l10n.tabTeams,
            ),
            NavigationDestination(
              icon: const Icon(Icons.domain_outlined, color: AppColors.textSecondary),
              selectedIcon: const Icon(Icons.domain, color: AppColors.primary),
              label: l10n.tabClub,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
              selectedIcon: const Icon(Icons.person, color: AppColors.primary),
              label: l10n.tabProfile,
            ),
          ],
        ),
      ),
    );
  }
}
