// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appSubtitle => 'Volley';

  @override
  String get fieldRequired => 'Champ requis';

  @override
  String get loginTitle => 'SKYBALL';

  @override
  String get loginUsername => 'Nom d\'utilisateur';

  @override
  String get loginPassword => 'Mot de passe';

  @override
  String get loginButton => 'SE CONNECTER';

  @override
  String get loginNoAccount => 'Pas encore inscrit ? ';

  @override
  String get loginCreateAccount => 'Créer un compte';

  @override
  String get loginErrorInvalidCredentials => 'Identifiants incorrects.';

  @override
  String get loginErrorNotVerified =>
      'Compte non vérifié. Vérifiez vos emails.';

  @override
  String get loginErrorGeneric => 'Une erreur est survenue. Réessayez.';

  @override
  String get registerTitle => 'CRÉER UN COMPTE';

  @override
  String get registerSubtitle => 'Rejoins la communauté Skyball';

  @override
  String get registerUsername => 'Nom d\'utilisateur';

  @override
  String get registerEmail => 'Adresse email';

  @override
  String get registerEmailInvalid => 'Email invalide';

  @override
  String get registerPassword => 'Mot de passe';

  @override
  String get registerPasswordTooShort => 'Minimum 6 caractères';

  @override
  String get registerConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get registerPasswordMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get registerButton => 'CRÉER MON COMPTE';

  @override
  String get registerAlreadyAccount => 'Déjà inscrit ? ';

  @override
  String get registerLoginLink => 'Se connecter';

  @override
  String get registerSuccessTitle => 'Inscription réussie';

  @override
  String get registerError409 => 'Nom d\'utilisateur ou email déjà utilisé.';

  @override
  String get registerError400 =>
      'Données invalides. Vérifiez vos informations.';

  @override
  String get registerErrorGeneric => 'Une erreur est survenue. Réessayez.';

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabMatches => 'Matchs';

  @override
  String get tabTeams => 'Équipes';

  @override
  String get tabProfile => 'Profil';

  @override
  String homeGreeting(String username) {
    return 'Salut, $username !';
  }

  @override
  String get homeNextMatch => 'Prochain match';

  @override
  String get homeRecentResults => 'Derniers résultats';

  @override
  String get homeNoTeam => 'Rejoignez une équipe pour voir vos matchs.';

  @override
  String get homeNoUpcomingMatch => 'Aucun match à venir.';

  @override
  String get homeNoRecentResults => 'Aucun résultat récent.';

  @override
  String get homeHome => 'Domicile';

  @override
  String get homeAway => 'Extérieur';

  @override
  String get homeVs => 'vs';

  @override
  String get homeWin => 'Victoire';

  @override
  String get homeLoss => 'Défaite';

  @override
  String get homeDraw => 'Nul';

  @override
  String get homeRetry => 'Réessayer';

  @override
  String get homeLoadError => 'Impossible de charger les données.';

  @override
  String get teamCategory => 'Catégorie';

  @override
  String get teamGender => 'Genre';

  @override
  String get teamClub => 'Club';

  @override
  String get teamMembers => 'Membres';

  @override
  String get teamNoMembers => 'Aucun membre.';

  @override
  String get teamViewMatches => 'Voir les matchs';

  @override
  String get teamLoadError => 'Impossible de charger l\'équipe.';

  @override
  String get tabClub => 'Club';

  @override
  String get clubMyClub => 'Mon club';

  @override
  String clubFounded(String year) {
    return 'Fondé en $year';
  }

  @override
  String get clubWebsite => 'Site web';

  @override
  String get clubNoClub => 'Tu n\'es dans aucun club';

  @override
  String get clubNoClubSub =>
      'Rejoins un club pour accéder à ses équipes et ses compétitions.';

  @override
  String get clubFindClub => 'Trouver un club';

  @override
  String get clubLeave => 'Quitter le club';

  @override
  String get clubLeaveConfirm => 'Quitter le club ?';

  @override
  String get clubLeaveConfirmMessage =>
      'Cette action retirera aussi toutes tes adhésions aux équipes de ce club.';

  @override
  String get clubTeams => 'Équipes du club';

  @override
  String clubAutoJoinTitle(String clubName) {
    return 'Rejoindre $clubName ?';
  }

  @override
  String clubAutoJoinMessage(String clubName) {
    return 'Cette équipe appartient à $clubName. Tu vas automatiquement rejoindre ce club.';
  }

  @override
  String get teamsMyTeams => 'Mes équipes';

  @override
  String get teamsExplore => 'Explorer';

  @override
  String get teamsJoin => 'Rejoindre';

  @override
  String get teamsLeave => 'Quitter';

  @override
  String get teamsNoMyTeams =>
      'Tu ne fais partie d\'aucune équipe pour l\'instant.';

  @override
  String get teamsLoadError => 'Impossible de charger les équipes.';

  @override
  String get teamsDifferentClub => 'Tu appartiens déjà à un autre club.';

  @override
  String get confirm => 'Confirmer';

  @override
  String get cancel => 'Annuler';

  @override
  String get member => 'Membre';

  @override
  String get profileEdit => 'Modifier le profil';

  @override
  String get profileLogout => 'Se déconnecter';

  @override
  String get profileLogoutConfirm => 'Se déconnecter ?';

  @override
  String get profileLogoutMessage =>
      'Tu seras redirigé vers la page de connexion.';

  @override
  String profileTeams(int count) {
    return '$count équipe(s)';
  }

  @override
  String get matchesUpcoming => 'À venir';

  @override
  String get matchesResults => 'Résultats';

  @override
  String get matchesNoUpcoming => 'Aucun match à venir.';

  @override
  String get matchesNoResults => 'Aucun résultat.';

  @override
  String get matchesLoadError => 'Impossible de charger les matchs.';

  @override
  String get matchesMyMatches => 'Mes matchs';

  @override
  String get matchesChampionships => 'Championnats';

  @override
  String get champLoadError => 'Impossible de charger le championnat.';

  @override
  String get champNoChampionships => 'Aucun championnat pour l\'instant.';

  @override
  String get champNew => 'Nouveau championnat';

  @override
  String get champEdit => 'Modifier le championnat';

  @override
  String get champName => 'Nom';

  @override
  String get champSeason => 'Saison';

  @override
  String get champCategory => 'Catégorie';

  @override
  String get champSave => 'Enregistrer';

  @override
  String get champMatches => 'Matchs';

  @override
  String get champNoMatches => 'Aucun match dans ce championnat.';

  @override
  String get champDelete => 'Supprimer';

  @override
  String get champDeleteConfirm => 'Supprimer le championnat ?';

  @override
  String champDeleteConfirmMessage(String name) {
    return '« $name » sera définitivement supprimé.';
  }

  @override
  String get matchLoadError => 'Impossible de charger le match.';

  @override
  String get matchDelete => 'Supprimer';

  @override
  String get matchDeleteConfirm => 'Supprimer le match ?';

  @override
  String get matchDeleteConfirmMessage =>
      'Ce match et ses données seront définitivement supprimés.';

  @override
  String get matchSets => 'Sets';

  @override
  String get matchNoSets => 'Aucun set saisi.';

  @override
  String get matchAddSet => 'Ajouter un set';

  @override
  String get matchSet => 'Set';

  @override
  String get matchPlayers => 'Joueurs';

  @override
  String get matchNoPlayers => 'Aucun joueur.';

  @override
  String get matchCaptain => 'Capitaine';

  @override
  String get matchSetCaptain => 'Définir capitaine';

  @override
  String get matchTeamPoints => 'Mon équipe';

  @override
  String get matchOpponentPoints => 'Adversaire';

  @override
  String get attendancePresent => 'Présent';

  @override
  String get attendanceAbsent => 'Absent';

  @override
  String get attendanceUnknown => 'Indéterminé';

  @override
  String get matchStatusScheduled => 'Prévu';

  @override
  String get matchStatusPlayed => 'Joué';

  @override
  String get matchStatusCancelled => 'Annulé';

  @override
  String get matchStatusPostponed => 'Reporté';

  @override
  String get matchStatusForfeit => 'Forfait';

  @override
  String get matchCreate => 'Nouveau match';

  @override
  String get matchEditTitle => 'Modifier le match';

  @override
  String get matchTeam => 'Équipe';

  @override
  String get matchOpponent => 'Adversaire';

  @override
  String get matchDate => 'Date';

  @override
  String get matchPickDate => 'Choisir une date';

  @override
  String get matchLocation => 'Lieu';

  @override
  String get matchHome => 'À domicile';

  @override
  String get matchChampionship => 'Championnat';

  @override
  String get matchNoChampionship => 'Aucun';

  @override
  String get matchStatus => 'Statut';

  @override
  String get matchForfeitedBy => 'Forfait de';

  @override
  String get matchCoachMessage => 'Message du coach';

  @override
  String get matchDateRequired => 'Date requise';

  @override
  String get matchTeamRequired => 'Sélectionne une équipe';

  @override
  String get clubName => 'Nom';

  @override
  String get clubCreate => 'Créer un club';

  @override
  String get clubEdit => 'Modifier le club';

  @override
  String get clubDelete => 'Supprimer';

  @override
  String get clubDeleteConfirm => 'Supprimer le club ?';

  @override
  String clubDeleteConfirmMessage(String name) {
    return '« $name » et ses données seront définitivement supprimés.';
  }

  @override
  String get clubCity => 'Ville';

  @override
  String get clubDescription => 'Description';

  @override
  String get clubWebsiteUrl => 'Site web';

  @override
  String get clubLogoUrl => 'URL du logo';

  @override
  String get clubMembers => 'Membres';

  @override
  String get clubNoMembers => 'Aucun membre.';

  @override
  String get teamCreate => 'Créer une équipe';

  @override
  String get teamEdit => 'Modifier l\'équipe';

  @override
  String get teamDelete => 'Supprimer';

  @override
  String get teamDeleteConfirm => 'Supprimer l\'équipe ?';

  @override
  String teamDeleteConfirmMessage(String name) {
    return '« $name » et ses données seront définitivement supprimés.';
  }

  @override
  String get teamName => 'Nom';

  @override
  String get teamLogoUrl => 'URL du logo';

  @override
  String get teamGenderLabel => 'Genre';

  @override
  String get memberRemove => 'Retirer du groupe';

  @override
  String get roleMember => 'Membre';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get errorGeneric => 'Une erreur est survenue. Réessayez.';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get forgotTitle => 'Mot de passe oublié';

  @override
  String get forgotSubtitle =>
      'Saisis ton email pour recevoir un lien de réinitialisation.';

  @override
  String get forgotSendButton => 'Envoyer le lien';

  @override
  String get forgotSent =>
      'Si un compte existe pour cet email, un lien de réinitialisation a été envoyé.';

  @override
  String get forgotHaveCode => 'J\'ai déjà un code';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get resetTitle => 'Réinitialiser le mot de passe';

  @override
  String get resetSubtitle =>
      'Saisis le code reçu par email et ton nouveau mot de passe.';

  @override
  String get resetToken => 'Code de réinitialisation';

  @override
  String get resetNewPassword => 'Nouveau mot de passe';

  @override
  String get resetConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get resetButton => 'Réinitialiser';

  @override
  String get resetSuccess => 'Mot de passe réinitialisé. Tu peux te connecter.';

  @override
  String get verifyTitle => 'Vérifier l\'email';

  @override
  String get verifySubtitle => 'Saisis le code de vérification reçu par email.';

  @override
  String get verifyToken => 'Code de vérification';

  @override
  String get verifyButton => 'Vérifier';

  @override
  String get verifySuccess => 'Email vérifié. Tu peux te connecter.';

  @override
  String get verifyHaveCode => 'J\'ai un code de vérification';

  @override
  String get verifyResendButton => 'Renvoyer l\'email de vérification';

  @override
  String get verifyResendPrompt =>
      'Saisis ton email pour recevoir un nouveau lien.';

  @override
  String get verifyResendSent =>
      'Email de vérification envoyé. Vérifie ta boîte de réception.';

  @override
  String get profileDangerZone => 'Zone sensible';

  @override
  String get profileDeleteAccount => 'Supprimer mon compte';

  @override
  String get profileDeleteConfirm => 'Supprimer le compte ?';

  @override
  String get profileDeleteMessage =>
      'Cette action est irréversible. Toutes tes données seront définitivement supprimées.';

  @override
  String get profileDeleteButton => 'Supprimer définitivement';

  @override
  String get memberAdd => 'Ajouter un membre';

  @override
  String get memberPickTitle => 'Ajouter un membre';

  @override
  String get memberSearchHint => 'Rechercher par nom ou email';

  @override
  String get memberNoResults => 'Aucun utilisateur trouvé.';

  @override
  String get memberAlreadyIn => 'Déjà membre';

  @override
  String get memberAdded => 'Membre ajouté.';
}
