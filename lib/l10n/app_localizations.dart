import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// No description provided for @appSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Volley'**
  String get appSubtitle;

  /// No description provided for @fieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Champ requis'**
  String get fieldRequired;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'SKYBALL'**
  String get loginTitle;

  /// No description provided for @loginUsername.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get loginUsername;

  /// No description provided for @loginPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'SE CONNECTER'**
  String get loginButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore inscrit ? '**
  String get loginNoAccount;

  /// No description provided for @loginCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get loginCreateAccount;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants incorrects.'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @loginErrorNotVerified.
  ///
  /// In fr, this message translates to:
  /// **'Compte non vérifié. Vérifiez vos emails.'**
  String get loginErrorNotVerified;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get loginErrorGeneric;

  /// No description provided for @registerTitle.
  ///
  /// In fr, this message translates to:
  /// **'CRÉER UN COMPTE'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoins la communauté Skyball'**
  String get registerSubtitle;

  /// No description provided for @registerUsername.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get registerUsername;

  /// No description provided for @registerEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email'**
  String get registerEmail;

  /// No description provided for @registerEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get registerEmailInvalid;

  /// No description provided for @registerPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get registerPassword;

  /// No description provided for @registerPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 6 caractères'**
  String get registerPasswordTooShort;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get registerConfirmPassword;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get registerPasswordMismatch;

  /// No description provided for @registerButton.
  ///
  /// In fr, this message translates to:
  /// **'CRÉER MON COMPTE'**
  String get registerButton;

  /// No description provided for @registerAlreadyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà inscrit ? '**
  String get registerAlreadyAccount;

  /// No description provided for @registerLoginLink.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get registerLoginLink;

  /// No description provided for @registerSuccessTitle.
  ///
  /// In fr, this message translates to:
  /// **'Inscription réussie'**
  String get registerSuccessTitle;

  /// No description provided for @registerError409.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur ou email déjà utilisé.'**
  String get registerError409;

  /// No description provided for @registerError400.
  ///
  /// In fr, this message translates to:
  /// **'Données invalides. Vérifiez vos informations.'**
  String get registerError400;

  /// No description provided for @registerErrorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get registerErrorGeneric;

  /// No description provided for @tabHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get tabHome;

  /// No description provided for @tabMatches.
  ///
  /// In fr, this message translates to:
  /// **'Matchs'**
  String get tabMatches;

  /// No description provided for @tabTeams.
  ///
  /// In fr, this message translates to:
  /// **'Équipes'**
  String get tabTeams;

  /// No description provided for @tabProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @homeGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Salut, {username} !'**
  String homeGreeting(String username);

  /// No description provided for @homeNextMatch.
  ///
  /// In fr, this message translates to:
  /// **'Prochain match'**
  String get homeNextMatch;

  /// No description provided for @homeRecentResults.
  ///
  /// In fr, this message translates to:
  /// **'Derniers résultats'**
  String get homeRecentResults;

  /// No description provided for @homeNoTeam.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez une équipe pour voir vos matchs.'**
  String get homeNoTeam;

  /// No description provided for @homeNoUpcomingMatch.
  ///
  /// In fr, this message translates to:
  /// **'Aucun match à venir.'**
  String get homeNoUpcomingMatch;

  /// No description provided for @homeNoRecentResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat récent.'**
  String get homeNoRecentResults;

  /// No description provided for @homeHome.
  ///
  /// In fr, this message translates to:
  /// **'Domicile'**
  String get homeHome;

  /// No description provided for @homeAway.
  ///
  /// In fr, this message translates to:
  /// **'Extérieur'**
  String get homeAway;

  /// No description provided for @homeVs.
  ///
  /// In fr, this message translates to:
  /// **'vs'**
  String get homeVs;

  /// No description provided for @homeWin.
  ///
  /// In fr, this message translates to:
  /// **'Victoire'**
  String get homeWin;

  /// No description provided for @homeLoss.
  ///
  /// In fr, this message translates to:
  /// **'Défaite'**
  String get homeLoss;

  /// No description provided for @homeDraw.
  ///
  /// In fr, this message translates to:
  /// **'Nul'**
  String get homeDraw;

  /// No description provided for @homeRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get homeRetry;

  /// No description provided for @homeLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les données.'**
  String get homeLoadError;

  /// No description provided for @teamCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get teamCategory;

  /// No description provided for @teamGender.
  ///
  /// In fr, this message translates to:
  /// **'Genre'**
  String get teamGender;

  /// No description provided for @teamClub.
  ///
  /// In fr, this message translates to:
  /// **'Club'**
  String get teamClub;

  /// No description provided for @teamMembers.
  ///
  /// In fr, this message translates to:
  /// **'Membres'**
  String get teamMembers;

  /// No description provided for @teamNoMembers.
  ///
  /// In fr, this message translates to:
  /// **'Aucun membre.'**
  String get teamNoMembers;

  /// No description provided for @teamViewMatches.
  ///
  /// In fr, this message translates to:
  /// **'Voir les matchs'**
  String get teamViewMatches;

  /// No description provided for @teamLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger l\'équipe.'**
  String get teamLoadError;

  /// No description provided for @tabClub.
  ///
  /// In fr, this message translates to:
  /// **'Club'**
  String get tabClub;

  /// No description provided for @clubMyClub.
  ///
  /// In fr, this message translates to:
  /// **'Mon club'**
  String get clubMyClub;

  /// No description provided for @clubFounded.
  ///
  /// In fr, this message translates to:
  /// **'Fondé en {year}'**
  String clubFounded(String year);

  /// No description provided for @clubWebsite.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get clubWebsite;

  /// No description provided for @clubNoClub.
  ///
  /// In fr, this message translates to:
  /// **'Tu n\'es dans aucun club'**
  String get clubNoClub;

  /// No description provided for @clubNoClubSub.
  ///
  /// In fr, this message translates to:
  /// **'Rejoins un club pour accéder à ses équipes et ses compétitions.'**
  String get clubNoClubSub;

  /// No description provided for @clubFindClub.
  ///
  /// In fr, this message translates to:
  /// **'Trouver un club'**
  String get clubFindClub;

  /// No description provided for @clubLeave.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le club'**
  String get clubLeave;

  /// No description provided for @clubLeaveConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le club ?'**
  String get clubLeaveConfirm;

  /// No description provided for @clubLeaveConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette action retirera aussi toutes tes adhésions aux équipes de ce club.'**
  String get clubLeaveConfirmMessage;

  /// No description provided for @clubTeams.
  ///
  /// In fr, this message translates to:
  /// **'Équipes du club'**
  String get clubTeams;

  /// No description provided for @clubAutoJoinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre {clubName} ?'**
  String clubAutoJoinTitle(String clubName);

  /// No description provided for @clubAutoJoinMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette équipe appartient à {clubName}. Tu vas automatiquement rejoindre ce club.'**
  String clubAutoJoinMessage(String clubName);

  /// No description provided for @teamsMyTeams.
  ///
  /// In fr, this message translates to:
  /// **'Mes équipes'**
  String get teamsMyTeams;

  /// No description provided for @teamsExplore.
  ///
  /// In fr, this message translates to:
  /// **'Explorer'**
  String get teamsExplore;

  /// No description provided for @teamsJoin.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre'**
  String get teamsJoin;

  /// No description provided for @teamsLeave.
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get teamsLeave;

  /// No description provided for @teamsNoMyTeams.
  ///
  /// In fr, this message translates to:
  /// **'Tu ne fais partie d\'aucune équipe pour l\'instant.'**
  String get teamsNoMyTeams;

  /// No description provided for @teamsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les équipes.'**
  String get teamsLoadError;

  /// No description provided for @teamsDifferentClub.
  ///
  /// In fr, this message translates to:
  /// **'Tu appartiens déjà à un autre club.'**
  String get teamsDifferentClub;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @member.
  ///
  /// In fr, this message translates to:
  /// **'Membre'**
  String get member;

  /// No description provided for @profileEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get profileEdit;

  /// No description provided for @profileLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter ?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileLogoutMessage.
  ///
  /// In fr, this message translates to:
  /// **'Tu seras redirigé vers la page de connexion.'**
  String get profileLogoutMessage;

  /// No description provided for @profileTeams.
  ///
  /// In fr, this message translates to:
  /// **'{count} équipe(s)'**
  String profileTeams(int count);

  /// No description provided for @matchesUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get matchesUpcoming;

  /// No description provided for @matchesResults.
  ///
  /// In fr, this message translates to:
  /// **'Résultats'**
  String get matchesResults;

  /// No description provided for @matchesNoUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'Aucun match à venir.'**
  String get matchesNoUpcoming;

  /// No description provided for @matchesNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat.'**
  String get matchesNoResults;

  /// No description provided for @matchesLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les matchs.'**
  String get matchesLoadError;

  /// No description provided for @matchesMyMatches.
  ///
  /// In fr, this message translates to:
  /// **'Mes matchs'**
  String get matchesMyMatches;

  /// No description provided for @matchesChampionships.
  ///
  /// In fr, this message translates to:
  /// **'Championnats'**
  String get matchesChampionships;

  /// No description provided for @champLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le championnat.'**
  String get champLoadError;

  /// No description provided for @champNoChampionships.
  ///
  /// In fr, this message translates to:
  /// **'Aucun championnat pour l\'instant.'**
  String get champNoChampionships;

  /// No description provided for @champNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau championnat'**
  String get champNew;

  /// No description provided for @champEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le championnat'**
  String get champEdit;

  /// No description provided for @champName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get champName;

  /// No description provided for @champSeason.
  ///
  /// In fr, this message translates to:
  /// **'Saison'**
  String get champSeason;

  /// No description provided for @champCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get champCategory;

  /// No description provided for @champSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get champSave;

  /// No description provided for @champMatches.
  ///
  /// In fr, this message translates to:
  /// **'Matchs'**
  String get champMatches;

  /// No description provided for @champNoMatches.
  ///
  /// In fr, this message translates to:
  /// **'Aucun match dans ce championnat.'**
  String get champNoMatches;

  /// No description provided for @champDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get champDelete;

  /// No description provided for @champDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le championnat ?'**
  String get champDeleteConfirm;

  /// No description provided for @champDeleteConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » sera définitivement supprimé.'**
  String champDeleteConfirmMessage(String name);

  /// No description provided for @matchLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le match.'**
  String get matchLoadError;

  /// No description provided for @matchDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get matchDelete;

  /// No description provided for @matchDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le match ?'**
  String get matchDeleteConfirm;

  /// No description provided for @matchDeleteConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ce match et ses données seront définitivement supprimés.'**
  String get matchDeleteConfirmMessage;

  /// No description provided for @matchSets.
  ///
  /// In fr, this message translates to:
  /// **'Sets'**
  String get matchSets;

  /// No description provided for @matchNoSets.
  ///
  /// In fr, this message translates to:
  /// **'Aucun set saisi.'**
  String get matchNoSets;

  /// No description provided for @matchAddSet.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un set'**
  String get matchAddSet;

  /// No description provided for @matchSet.
  ///
  /// In fr, this message translates to:
  /// **'Set'**
  String get matchSet;

  /// No description provided for @matchPlayers.
  ///
  /// In fr, this message translates to:
  /// **'Joueurs'**
  String get matchPlayers;

  /// No description provided for @matchNoPlayers.
  ///
  /// In fr, this message translates to:
  /// **'Aucun joueur.'**
  String get matchNoPlayers;

  /// No description provided for @matchCaptain.
  ///
  /// In fr, this message translates to:
  /// **'Capitaine'**
  String get matchCaptain;

  /// No description provided for @matchSetCaptain.
  ///
  /// In fr, this message translates to:
  /// **'Définir capitaine'**
  String get matchSetCaptain;

  /// No description provided for @matchTeamPoints.
  ///
  /// In fr, this message translates to:
  /// **'Mon équipe'**
  String get matchTeamPoints;

  /// No description provided for @matchOpponentPoints.
  ///
  /// In fr, this message translates to:
  /// **'Adversaire'**
  String get matchOpponentPoints;

  /// No description provided for @attendancePresent.
  ///
  /// In fr, this message translates to:
  /// **'Présent'**
  String get attendancePresent;

  /// No description provided for @attendanceAbsent.
  ///
  /// In fr, this message translates to:
  /// **'Absent'**
  String get attendanceAbsent;

  /// No description provided for @attendanceUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Indéterminé'**
  String get attendanceUnknown;

  /// No description provided for @matchStatusScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Prévu'**
  String get matchStatusScheduled;

  /// No description provided for @matchStatusPlayed.
  ///
  /// In fr, this message translates to:
  /// **'Joué'**
  String get matchStatusPlayed;

  /// No description provided for @matchStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get matchStatusCancelled;

  /// No description provided for @matchStatusPostponed.
  ///
  /// In fr, this message translates to:
  /// **'Reporté'**
  String get matchStatusPostponed;

  /// No description provided for @matchStatusForfeit.
  ///
  /// In fr, this message translates to:
  /// **'Forfait'**
  String get matchStatusForfeit;

  /// No description provided for @matchCreate.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau match'**
  String get matchCreate;

  /// No description provided for @matchEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le match'**
  String get matchEditTitle;

  /// No description provided for @matchTeam.
  ///
  /// In fr, this message translates to:
  /// **'Équipe'**
  String get matchTeam;

  /// No description provided for @matchOpponent.
  ///
  /// In fr, this message translates to:
  /// **'Adversaire'**
  String get matchOpponent;

  /// No description provided for @matchDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get matchDate;

  /// No description provided for @matchPickDate.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une date'**
  String get matchPickDate;

  /// No description provided for @matchLocation.
  ///
  /// In fr, this message translates to:
  /// **'Lieu'**
  String get matchLocation;

  /// No description provided for @matchHome.
  ///
  /// In fr, this message translates to:
  /// **'À domicile'**
  String get matchHome;

  /// No description provided for @matchChampionship.
  ///
  /// In fr, this message translates to:
  /// **'Championnat'**
  String get matchChampionship;

  /// No description provided for @matchNoChampionship.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get matchNoChampionship;

  /// No description provided for @matchStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get matchStatus;

  /// No description provided for @matchForfeitedBy.
  ///
  /// In fr, this message translates to:
  /// **'Forfait de'**
  String get matchForfeitedBy;

  /// No description provided for @matchCoachMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message du coach'**
  String get matchCoachMessage;

  /// No description provided for @matchDateRequired.
  ///
  /// In fr, this message translates to:
  /// **'Date requise'**
  String get matchDateRequired;

  /// No description provided for @matchTeamRequired.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionne une équipe'**
  String get matchTeamRequired;

  /// No description provided for @clubName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get clubName;

  /// No description provided for @clubCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer un club'**
  String get clubCreate;

  /// No description provided for @clubEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le club'**
  String get clubEdit;

  /// No description provided for @clubDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get clubDelete;

  /// No description provided for @clubDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le club ?'**
  String get clubDeleteConfirm;

  /// No description provided for @clubDeleteConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » et ses données seront définitivement supprimés.'**
  String clubDeleteConfirmMessage(String name);

  /// No description provided for @clubCity.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get clubCity;

  /// No description provided for @clubDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get clubDescription;

  /// No description provided for @clubWebsiteUrl.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get clubWebsiteUrl;

  /// No description provided for @clubLogoUrl.
  ///
  /// In fr, this message translates to:
  /// **'URL du logo'**
  String get clubLogoUrl;

  /// No description provided for @clubMembers.
  ///
  /// In fr, this message translates to:
  /// **'Membres'**
  String get clubMembers;

  /// No description provided for @clubNoMembers.
  ///
  /// In fr, this message translates to:
  /// **'Aucun membre.'**
  String get clubNoMembers;

  /// No description provided for @teamCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer une équipe'**
  String get teamCreate;

  /// No description provided for @teamEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'équipe'**
  String get teamEdit;

  /// No description provided for @teamDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get teamDelete;

  /// No description provided for @teamDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'équipe ?'**
  String get teamDeleteConfirm;

  /// No description provided for @teamDeleteConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » et ses données seront définitivement supprimés.'**
  String teamDeleteConfirmMessage(String name);

  /// No description provided for @teamName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get teamName;

  /// No description provided for @teamLogoUrl.
  ///
  /// In fr, this message translates to:
  /// **'URL du logo'**
  String get teamLogoUrl;

  /// No description provided for @teamGenderLabel.
  ///
  /// In fr, this message translates to:
  /// **'Genre'**
  String get teamGenderLabel;

  /// No description provided for @memberRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer du groupe'**
  String get memberRemove;

  /// No description provided for @roleMember.
  ///
  /// In fr, this message translates to:
  /// **'Membre'**
  String get roleMember;

  /// No description provided for @roleManager.
  ///
  /// In fr, this message translates to:
  /// **'Manager'**
  String get roleManager;

  /// No description provided for @roleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get errorGeneric;

  /// No description provided for @loginForgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get loginForgotPassword;

  /// No description provided for @forgotTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisis ton email pour recevoir un lien de réinitialisation.'**
  String get forgotSubtitle;

  /// No description provided for @forgotSendButton.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le lien'**
  String get forgotSendButton;

  /// No description provided for @forgotSent.
  ///
  /// In fr, this message translates to:
  /// **'Si un compte existe pour cet email, un lien de réinitialisation a été envoyé.'**
  String get forgotSent;

  /// No description provided for @forgotHaveCode.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai déjà un code'**
  String get forgotHaveCode;

  /// No description provided for @backToLogin.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la connexion'**
  String get backToLogin;

  /// No description provided for @resetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisis le code reçu par email et ton nouveau mot de passe.'**
  String get resetSubtitle;

  /// No description provided for @resetToken.
  ///
  /// In fr, this message translates to:
  /// **'Code de réinitialisation'**
  String get resetToken;

  /// No description provided for @resetNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get resetNewPassword;

  /// No description provided for @resetConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get resetConfirmPassword;

  /// No description provided for @resetButton.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get resetButton;

  /// No description provided for @resetSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe réinitialisé. Tu peux te connecter.'**
  String get resetSuccess;

  /// No description provided for @verifyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier l\'email'**
  String get verifyTitle;

  /// No description provided for @verifySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisis le code de vérification reçu par email.'**
  String get verifySubtitle;

  /// No description provided for @verifyToken.
  ///
  /// In fr, this message translates to:
  /// **'Code de vérification'**
  String get verifyToken;

  /// No description provided for @verifyButton.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get verifyButton;

  /// No description provided for @verifySuccess.
  ///
  /// In fr, this message translates to:
  /// **'Email vérifié. Tu peux te connecter.'**
  String get verifySuccess;

  /// No description provided for @verifyHaveCode.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai un code de vérification'**
  String get verifyHaveCode;

  /// No description provided for @verifyResendButton.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer l\'email de vérification'**
  String get verifyResendButton;

  /// No description provided for @verifyResendPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Saisis ton email pour recevoir un nouveau lien.'**
  String get verifyResendPrompt;

  /// No description provided for @verifyResendSent.
  ///
  /// In fr, this message translates to:
  /// **'Email de vérification envoyé. Vérifie ta boîte de réception.'**
  String get verifyResendSent;

  /// No description provided for @profileDangerZone.
  ///
  /// In fr, this message translates to:
  /// **'Zone sensible'**
  String get profileDangerZone;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte ?'**
  String get profileDeleteConfirm;

  /// No description provided for @profileDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible. Toutes tes données seront définitivement supprimées.'**
  String get profileDeleteMessage;

  /// No description provided for @profileDeleteButton.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement'**
  String get profileDeleteButton;

  /// No description provided for @memberAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un membre'**
  String get memberAdd;

  /// No description provided for @memberPickTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un membre'**
  String get memberPickTitle;

  /// No description provided for @memberSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher par nom ou email'**
  String get memberSearchHint;

  /// No description provided for @memberNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun utilisateur trouvé.'**
  String get memberNoResults;

  /// No description provided for @memberAlreadyIn.
  ///
  /// In fr, this message translates to:
  /// **'Déjà membre'**
  String get memberAlreadyIn;

  /// No description provided for @memberAdded.
  ///
  /// In fr, this message translates to:
  /// **'Membre ajouté.'**
  String get memberAdded;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
