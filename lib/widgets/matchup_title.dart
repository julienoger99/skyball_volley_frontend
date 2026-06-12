import 'package:flutter/material.dart';
import '../screens/team_detail_screen.dart';
import '../theme/app_theme.dart';

class MatchupTitle extends StatelessWidget {
  final Map<String, dynamic> match;
  final double fontSize;
  final Color? myTeamColor;
  final Color? opponentColor;
  final Color? separatorColor;

  const MatchupTitle({
    super.key,
    required this.match,
    this.fontSize = 18,
    this.myTeamColor,
    this.opponentColor,
    this.separatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final myTeamId = match['team']?['id'] as int?;
    final myTeamName = match['team']?['name'] as String? ?? '?';
    final opponentId = match['opponentTeamId'] as int?;
    final isHome = match['home'] == true;
    final opponentName =
        (isHome ? match['awayTeamName'] : match['homeTeamName']) as String? ?? '?';

    final homeName = isHome ? myTeamName : opponentName;
    final awayName = isHome ? opponentName : myTeamName;
    final homeId = isHome ? myTeamId : opponentId;
    final awayId = isHome ? opponentId : myTeamId;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _TeamLink(
          name: homeName,
          teamId: homeId,
          isMine: isHome,
          fontSize: fontSize,
          myTeamColor: myTeamColor ?? AppColors.teamHighlight,
          opponentColor: opponentColor ?? AppColors.textPrimary,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: fontSize * 0.4),
          child: Text(
            '·',
            style: TextStyle(
              color: separatorColor ?? AppColors.textSecondary,
              fontSize: fontSize * 1.1,
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
        ),
        _TeamLink(
          name: awayName,
          teamId: awayId,
          isMine: !isHome,
          fontSize: fontSize,
          myTeamColor: myTeamColor ?? AppColors.teamHighlight,
          opponentColor: opponentColor ?? AppColors.textPrimary,
        ),
      ],
    );
  }
}

class _TeamLink extends StatelessWidget {
  final String name;
  final int? teamId;
  final bool isMine;
  final double fontSize;
  final Color myTeamColor;
  final Color opponentColor;

  const _TeamLink({
    required this.name,
    required this.teamId,
    required this.isMine,
    required this.fontSize,
    required this.myTeamColor,
    required this.opponentColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: isMine ? myTeamColor : opponentColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );
    if (teamId == null) return Text(name, style: style);
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TeamDetailScreen(teamId: teamId!, initialName: name),
        ),
      ),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        child: Text(name, style: style),
      ),
    );
  }
}
