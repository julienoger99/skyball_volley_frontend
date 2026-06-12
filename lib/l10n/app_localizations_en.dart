// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appSubtitle => 'Volleyball';

  @override
  String get fieldRequired => 'Required field';

  @override
  String get loginTitle => 'SKYBALL';

  @override
  String get loginUsername => 'Username';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'LOG IN';

  @override
  String get loginNoAccount => 'Not registered yet? ';

  @override
  String get loginCreateAccount => 'Create an account';

  @override
  String get loginErrorInvalidCredentials => 'Invalid credentials.';

  @override
  String get loginErrorNotVerified =>
      'Account not verified. Check your emails.';

  @override
  String get loginErrorGeneric => 'An error occurred. Please try again.';

  @override
  String get registerTitle => 'CREATE AN ACCOUNT';

  @override
  String get registerSubtitle => 'Join the Skyball community';

  @override
  String get registerUsername => 'Username';

  @override
  String get registerEmail => 'Email address';

  @override
  String get registerEmailInvalid => 'Invalid email';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerPasswordTooShort => 'Minimum 6 characters';

  @override
  String get registerConfirmPassword => 'Confirm password';

  @override
  String get registerPasswordMismatch => 'Passwords do not match';

  @override
  String get registerButton => 'CREATE MY ACCOUNT';

  @override
  String get registerAlreadyAccount => 'Already registered? ';

  @override
  String get registerLoginLink => 'Log in';

  @override
  String get registerSuccessTitle => 'Registration successful';

  @override
  String get registerError409 => 'Username or email already in use.';

  @override
  String get registerError400 => 'Invalid data. Please check your information.';

  @override
  String get registerErrorGeneric => 'An error occurred. Please try again.';

  @override
  String get tabHome => 'Home';

  @override
  String get tabMatches => 'Matches';

  @override
  String get tabTeams => 'Teams';

  @override
  String get tabProfile => 'Profile';

  @override
  String homeGreeting(String username) {
    return 'Hi, $username!';
  }

  @override
  String get homeNextMatch => 'Next match';

  @override
  String get homeRecentResults => 'Recent results';

  @override
  String get homeNoTeam => 'Join a team to see your matches.';

  @override
  String get homeNoUpcomingMatch => 'No upcoming match.';

  @override
  String get homeNoRecentResults => 'No recent results.';

  @override
  String get homeHome => 'Home';

  @override
  String get homeAway => 'Away';

  @override
  String get homeVs => 'vs';

  @override
  String get homeWin => 'Win';

  @override
  String get homeLoss => 'Loss';

  @override
  String get homeDraw => 'Draw';

  @override
  String get homeRetry => 'Retry';

  @override
  String get homeLoadError => 'Unable to load data.';

  @override
  String get teamCategory => 'Category';

  @override
  String get teamGender => 'Gender';

  @override
  String get teamClub => 'Club';

  @override
  String get teamMembers => 'Members';

  @override
  String get teamNoMembers => 'No members.';

  @override
  String get teamViewMatches => 'View matches';

  @override
  String get teamLoadError => 'Unable to load team.';

  @override
  String get tabClub => 'Club';

  @override
  String get clubMyClub => 'My club';

  @override
  String clubFounded(String year) {
    return 'Founded in $year';
  }

  @override
  String get clubWebsite => 'Website';

  @override
  String get clubNoClub => 'You\'re not in any club';

  @override
  String get clubNoClubSub =>
      'Join a club to access its teams and competitions.';

  @override
  String get clubFindClub => 'Find a club';

  @override
  String get clubLeave => 'Leave club';

  @override
  String get clubLeaveConfirm => 'Leave the club?';

  @override
  String get clubLeaveConfirmMessage =>
      'This will also remove you from all teams in this club.';

  @override
  String get clubTeams => 'Club teams';

  @override
  String clubAutoJoinTitle(String clubName) {
    return 'Join $clubName?';
  }

  @override
  String clubAutoJoinMessage(String clubName) {
    return 'This team belongs to $clubName. You will automatically join this club.';
  }

  @override
  String get teamsMyTeams => 'My teams';

  @override
  String get teamsExplore => 'Explore';

  @override
  String get teamsJoin => 'Join';

  @override
  String get teamsLeave => 'Leave';

  @override
  String get teamsNoMyTeams => 'You are not in any team yet.';

  @override
  String get teamsLoadError => 'Unable to load teams.';

  @override
  String get teamsDifferentClub => 'You already belong to a different club.';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get member => 'Member';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileLogoutConfirm => 'Log out?';

  @override
  String get profileLogoutMessage =>
      'You will be redirected to the login page.';

  @override
  String profileTeams(int count) {
    return '$count team(s)';
  }

  @override
  String get matchesUpcoming => 'Upcoming';

  @override
  String get matchesResults => 'Results';

  @override
  String get matchesNoUpcoming => 'No upcoming match.';

  @override
  String get matchesNoResults => 'No results.';

  @override
  String get matchesLoadError => 'Unable to load matches.';

  @override
  String get matchesMyMatches => 'My matches';

  @override
  String get matchesChampionships => 'Championships';

  @override
  String get champLoadError => 'Unable to load the championship.';

  @override
  String get champNoChampionships => 'No championship yet.';

  @override
  String get champNew => 'New championship';

  @override
  String get champEdit => 'Edit championship';

  @override
  String get champName => 'Name';

  @override
  String get champSeason => 'Season';

  @override
  String get champCategory => 'Category';

  @override
  String get champSave => 'Save';

  @override
  String get champMatches => 'Matches';

  @override
  String get champNoMatches => 'No match in this championship.';

  @override
  String get champDelete => 'Delete';

  @override
  String get champDeleteConfirm => 'Delete championship?';

  @override
  String champDeleteConfirmMessage(String name) {
    return '\"$name\" will be permanently deleted.';
  }

  @override
  String get matchLoadError => 'Unable to load the match.';

  @override
  String get matchDelete => 'Delete';

  @override
  String get matchDeleteConfirm => 'Delete match?';

  @override
  String get matchDeleteConfirmMessage =>
      'This match and its data will be permanently deleted.';

  @override
  String get matchSets => 'Sets';

  @override
  String get matchNoSets => 'No set recorded.';

  @override
  String get matchAddSet => 'Add a set';

  @override
  String get matchSet => 'Set';

  @override
  String get matchPlayers => 'Players';

  @override
  String get matchNoPlayers => 'No player.';

  @override
  String get matchCaptain => 'Captain';

  @override
  String get matchSetCaptain => 'Set as captain';

  @override
  String get matchTeamPoints => 'My team';

  @override
  String get matchOpponentPoints => 'Opponent';

  @override
  String get attendancePresent => 'Present';

  @override
  String get attendanceAbsent => 'Absent';

  @override
  String get attendanceUnknown => 'Unknown';

  @override
  String get matchStatusScheduled => 'Scheduled';

  @override
  String get matchStatusPlayed => 'Played';

  @override
  String get matchStatusCancelled => 'Cancelled';

  @override
  String get matchStatusPostponed => 'Postponed';

  @override
  String get matchStatusForfeit => 'Forfeit';

  @override
  String get matchCreate => 'New match';

  @override
  String get matchEditTitle => 'Edit match';

  @override
  String get matchTeam => 'Team';

  @override
  String get matchOpponent => 'Opponent';

  @override
  String get matchDate => 'Date';

  @override
  String get matchPickDate => 'Pick a date';

  @override
  String get matchLocation => 'Location';

  @override
  String get matchHome => 'At home';

  @override
  String get matchChampionship => 'Championship';

  @override
  String get matchNoChampionship => 'None';

  @override
  String get matchStatus => 'Status';

  @override
  String get matchForfeitedBy => 'Forfeited by';

  @override
  String get matchCoachMessage => 'Coach message';

  @override
  String get matchDateRequired => 'Date required';

  @override
  String get matchTeamRequired => 'Select a team';

  @override
  String get clubName => 'Name';

  @override
  String get clubCreate => 'Create a club';

  @override
  String get clubEdit => 'Edit club';

  @override
  String get clubDelete => 'Delete';

  @override
  String get clubDeleteConfirm => 'Delete club?';

  @override
  String clubDeleteConfirmMessage(String name) {
    return '\"$name\" and its data will be permanently deleted.';
  }

  @override
  String get clubCity => 'City';

  @override
  String get clubDescription => 'Description';

  @override
  String get clubWebsiteUrl => 'Website';

  @override
  String get clubLogoUrl => 'Logo URL';

  @override
  String get clubMembers => 'Members';

  @override
  String get clubNoMembers => 'No member.';

  @override
  String get teamCreate => 'Create a team';

  @override
  String get teamEdit => 'Edit team';

  @override
  String get teamDelete => 'Delete';

  @override
  String get teamDeleteConfirm => 'Delete team?';

  @override
  String teamDeleteConfirmMessage(String name) {
    return '\"$name\" and its data will be permanently deleted.';
  }

  @override
  String get teamName => 'Name';

  @override
  String get teamLogoUrl => 'Logo URL';

  @override
  String get teamGenderLabel => 'Gender';

  @override
  String get memberRemove => 'Remove from group';

  @override
  String get roleMember => 'Member';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get forgotTitle => 'Forgot password';

  @override
  String get forgotSubtitle => 'Enter your email to receive a reset link.';

  @override
  String get forgotSendButton => 'Send link';

  @override
  String get forgotSent =>
      'If an account exists for this email, a password reset link has been sent.';

  @override
  String get forgotHaveCode => 'I already have a code';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get resetTitle => 'Reset password';

  @override
  String get resetSubtitle =>
      'Enter the code received by email and your new password.';

  @override
  String get resetToken => 'Reset code';

  @override
  String get resetNewPassword => 'New password';

  @override
  String get resetConfirmPassword => 'Confirm password';

  @override
  String get resetButton => 'Reset';

  @override
  String get resetSuccess => 'Password reset. You can now log in.';

  @override
  String get verifyTitle => 'Verify email';

  @override
  String get verifySubtitle => 'Enter the verification code received by email.';

  @override
  String get verifyToken => 'Verification code';

  @override
  String get verifyButton => 'Verify';

  @override
  String get verifySuccess => 'Email verified. You can now log in.';

  @override
  String get verifyHaveCode => 'I have a verification code';

  @override
  String get verifyResendButton => 'Resend verification email';

  @override
  String get verifyResendPrompt => 'Enter your email to receive a new link.';

  @override
  String get verifyResendSent =>
      'Verification email sent. Please check your inbox.';

  @override
  String get profileDangerZone => 'Danger zone';

  @override
  String get profileDeleteAccount => 'Delete my account';

  @override
  String get profileDeleteConfirm => 'Delete account?';

  @override
  String get profileDeleteMessage =>
      'This action is irreversible. All your data will be permanently deleted.';

  @override
  String get profileDeleteButton => 'Delete permanently';

  @override
  String get memberAdd => 'Add a member';

  @override
  String get memberPickTitle => 'Add a member';

  @override
  String get memberSearchHint => 'Search by name or email';

  @override
  String get memberNoResults => 'No user found.';

  @override
  String get memberAlreadyIn => 'Already a member';

  @override
  String get memberAdded => 'Member added.';
}
