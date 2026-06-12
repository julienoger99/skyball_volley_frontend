<div align="center">

# 🏐 Skyball Volley

**Gérez votre saison de volley, du service au dernier point.**

Clubs, équipes, championnats, feuilles de match et présences — réunis dans une
application Flutter multiplateforme aux couleurs du Brésil.

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Material&nbsp;3](https://img.shields.io/badge/Material%203-1E003D?logo=materialdesign&logoColor=FFD100)
![i18n](https://img.shields.io/badge/i18n-FR%20·%20EN%20·%20PT-4ADE80)

</div>

---

Skyball Volley est le client **Flutter** de la plateforme Skyball. Il se branche sur
l'[API Spring Boot](../skyball-volley-backend) pour offrir aux joueurs, managers et
admins de club une expérience fluide : rejoindre une équipe, suivre les championnats,
remplir les feuilles de match et gérer les effectifs — le tout dans une interface
sombre **violet / jaune** inspirée de la *seleção* brésilienne.

> 🇧🇷 Thème **violet `#1E003D` + jaune Brésil `#FFD100`**, typographie **Exo 2**,
> et une pointe de rose pour faire ressortir *votre* équipe sur le terrain.

## 🏐 Sur le terrain — ce que l'appli sait faire

**Compte & accès**
- Inscription et connexion sécurisées (JWT stocké dans le *secure storage*)
- Mot de passe oublié → réinitialisation par code reçu par e‑mail
- Vérification d'e‑mail et renvoi du lien
- Modification du profil et suppression de compte

**Clubs**
- Créer / éditer / supprimer un club, le rejoindre ou le quitter
- Annuaire des membres avec rôles **Membre · Manager · Admin**
- Ajout d'un membre par un manager via la recherche d'utilisateurs

**Équipes**
- Équipes indépendantes ou rattachées à un club, par catégorie et genre
- Gestion des rôles et des effectifs, écran détail dédié

**Championnats**
- Liste, détail et CRUD complet, matchs rattachés au championnat

**Matchs**
- Feuille de match : sets, score, statut, message du coach
- Présences **Présent · Absent · Indéterminé** et désignation du capitaine
- Création / édition réservées aux managers ; un joueur ne change que *sa* présence

## 👕 La compo — stack technique

| Rôle | Choix |
|------|-------|
| Framework | **Flutter** (Material 3, Dart `^3.11.5`) |
| Réseau | **Dio** + intercepteur JWT |
| Stockage sécurisé | **flutter_secure_storage** |
| Typo & UI | **google_fonts** (Exo 2) |
| i18n | **flutter_localizations** + `gen-l10n` — FR · EN · PT |
| Cibles | Linux · Android · iOS · macOS · Windows · Web |

## 🚀 Coup d'envoi

**Échauffement** — il vous faut le [Flutter SDK](https://docs.flutter.dev/get-started/install)
et une instance de l'[API Skyball Volley](../skyball-volley-backend) qui tourne.

```bash
flutter pub get          # récupère les dépendances
flutter gen-l10n         # génère les traductions
flutter run -d linux     # lance l'appli (ou -d chrome / macos / windows / <device>)
```

Par défaut l'appli vise le backend en local. Pour changer l'URL, éditez
`_baseUrl` dans `lib/data/api_client.dart` :

```dart
const _baseUrl = 'http://localhost:8080/api/v1';
```

## 🗺️ Le plan de jeu — architecture

```
lib/
├── main.dart                 # point d'entrée + SplashScreen
├── data/
│   ├── api_client.dart       # Dio + JWT (interceptor) + secure storage
│   └── helpers/              # un query helper par domaine (couvre 100 % de l'API)
├── screens/
│   ├── login / register / forgot_password / verify_email / splash
│   ├── main_scaffold.dart    # 5 onglets en IndexedStack
│   ├── tabs/                 # home · matches · teams · club · profile
│   └── *_detail_screen.dart  # championnat · match · équipe
├── widgets/                  # form sheets, cartes, annuaire, sélecteur de langue
├── theme/app_theme.dart      # palette violet/jaune Brésil
└── l10n/                     # app_fr · app_en · app_pt (.arb)
```

**Conventions maison**
- Pas de modèles Dart : les réponses circulent en `Map<String, dynamic>` brutes.
- Un onglet / écran = `StatefulWidget` + `Future` chargé en `initState`, rendu via
  `FutureBuilder` (spinner → erreur + retry → contenu).
- Gating des actions : **Manager / Admin** gèrent, **Membre** ne touche qu'à sa donnée.
- Traductions : `lib/l10n/app_fr.arb` est la référence ; `flutter gen-l10n` régénère le reste.

## 🌍 Langues

Français 🇫🇷 · Anglais 🇬🇧 · Portugais 🇵🇹 — changement à la volée via le sélecteur en haut de l'écran.

---

<div align="center">

Partie de la plateforme **Skyball Volley** · API : [skyball-volley-backend](../skyball-volley-backend)

🏐 *Bom jogo !*

</div>
