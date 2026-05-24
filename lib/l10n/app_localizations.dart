import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mony'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Mony'**
  String get welcome;

  /// No description provided for @welcomeDescription.
  ///
  /// In fr, this message translates to:
  /// **'Prenez le contrôle total de vos finances personnelles avec une application simple et puissante.'**
  String get welcomeDescription;

  /// No description provided for @trackExpenses.
  ///
  /// In fr, this message translates to:
  /// **'Suivez vos dépenses'**
  String get trackExpenses;

  /// No description provided for @trackExpensesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez toutes vos transactions en quelques secondes et visualisez où va votre argent.'**
  String get trackExpensesDescription;

  /// No description provided for @manageBudgets.
  ///
  /// In fr, this message translates to:
  /// **'Gérez vos budgets'**
  String get manageBudgets;

  /// No description provided for @manageBudgetsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Créez des budgets mensuels pour chaque catégorie et recevez des alertes en temps réel.'**
  String get manageBudgetsDescription;

  /// No description provided for @analyzeFinances.
  ///
  /// In fr, this message translates to:
  /// **'Analysez vos finances'**
  String get analyzeFinances;

  /// No description provided for @analyzeFinancesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Obtenez des rapports détaillés et des graphiques pour comprendre vos habitudes financières.'**
  String get analyzeFinancesDescription;

  /// No description provided for @aiAssistant.
  ///
  /// In fr, this message translates to:
  /// **'Assistant IA personnalisé'**
  String get aiAssistant;

  /// No description provided for @aiAssistantDescription.
  ///
  /// In fr, this message translates to:
  /// **'Recevez des conseils adaptés à votre profil financier'**
  String get aiAssistantDescription;

  /// No description provided for @start.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get start;

  /// No description provided for @next.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get next;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get skip;

  /// No description provided for @languageAndCurrency.
  ///
  /// In fr, this message translates to:
  /// **'Langue & Devise'**
  String get languageAndCurrency;

  /// No description provided for @chooseLanguageAndCurrency.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre langue et votre devise préférées'**
  String get chooseLanguageAndCurrency;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @currency.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get currency;

  /// No description provided for @french.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @english.
  ///
  /// In fr, this message translates to:
  /// **'Anglais'**
  String get english;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get editProfile;

  /// No description provided for @account.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get account;

  /// No description provided for @application.
  ///
  /// In fr, this message translates to:
  /// **'Application'**
  String get application;

  /// No description provided for @darkMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @data.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get data;

  /// No description provided for @exportData.
  ///
  /// In fr, this message translates to:
  /// **'Exporter les données'**
  String get exportData;

  /// No description provided for @backup.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde'**
  String get backup;

  /// No description provided for @restore.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer'**
  String get restore;

  /// No description provided for @reset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get reset;

  /// No description provided for @resetAllData.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser toutes les données'**
  String get resetAllData;

  /// No description provided for @support.
  ///
  /// In fr, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In fr, this message translates to:
  /// **'Centre d\'aide'**
  String get helpCenter;

  /// No description provided for @sendFeedback.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un feedback'**
  String get sendFeedback;

  /// No description provided for @reportBug.
  ///
  /// In fr, this message translates to:
  /// **'Signaler un bug'**
  String get reportBug;

  /// No description provided for @rateApp.
  ///
  /// In fr, this message translates to:
  /// **'Évaluer l\'application'**
  String get rateApp;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

  /// No description provided for @aboutMony.
  ///
  /// In fr, this message translates to:
  /// **'À propos de Mony'**
  String get aboutMony;

  /// No description provided for @privacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get termsOfService;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logout;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @warning.
  ///
  /// In fr, this message translates to:
  /// **'Attention'**
  String get warning;

  /// No description provided for @irreversibleAction.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible !'**
  String get irreversibleAction;

  /// No description provided for @resetConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Cette action supprimera définitivement toutes vos données : transactions, catégories, budgets et paramètres.'**
  String get resetConfirmation;

  /// No description provided for @dataReset.
  ///
  /// In fr, this message translates to:
  /// **'Données réinitialisées'**
  String get dataReset;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @profileUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour'**
  String get profileUpdated;

  /// No description provided for @name.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get name;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// No description provided for @register.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get register;

  /// No description provided for @categories.
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get categories;

  /// No description provided for @newCategory.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle catégorie'**
  String get newCategory;

  /// No description provided for @editCategory.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la catégorie'**
  String get editCategory;

  /// No description provided for @budgets.
  ///
  /// In fr, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @statistics.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get statistics;

  /// No description provided for @transactions.
  ///
  /// In fr, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @addTransaction.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une transaction'**
  String get addTransaction;

  /// No description provided for @totalBalance.
  ///
  /// In fr, this message translates to:
  /// **'Solde total'**
  String get totalBalance;

  /// No description provided for @income.
  ///
  /// In fr, this message translates to:
  /// **'Revenu'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In fr, this message translates to:
  /// **'Dépense'**
  String get expenses;

  /// No description provided for @recentTransactions.
  ///
  /// In fr, this message translates to:
  /// **'Transactions récentes'**
  String get recentTransactions;

  /// No description provided for @seeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get seeAll;

  /// No description provided for @hello.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {name} 👋'**
  String hello(Object name);

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @noUser.
  ///
  /// In fr, this message translates to:
  /// **'Aucun utilisateur'**
  String get noUser;

  /// No description provided for @financialProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil financier : {profile}'**
  String financialProfile(Object profile);

  /// No description provided for @youAreA.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes un : {profile}'**
  String youAreA(Object profile);

  /// No description provided for @noTransaction.
  ///
  /// In fr, this message translates to:
  /// **'Aucune transaction'**
  String get noTransaction;

  /// No description provided for @startByAddingTransaction.
  ///
  /// In fr, this message translates to:
  /// **'Commencez par ajouter votre première transaction'**
  String get startByAddingTransaction;

  /// No description provided for @deleteTransaction.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la transaction'**
  String get deleteTransaction;

  /// No description provided for @confirmDeleteTransaction.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer cette transaction ?'**
  String get confirmDeleteTransaction;

  /// No description provided for @transactionDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Transaction supprimée'**
  String get transactionDeleted;

  /// No description provided for @type.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @description.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @amount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @category.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get category;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @newTransaction.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle transaction'**
  String get newTransaction;

  /// No description provided for @enterAmount.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un montant'**
  String get enterAmount;

  /// No description provided for @invalidAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant invalide'**
  String get invalidAmount;

  /// No description provided for @newCategoryShort.
  ///
  /// In fr, this message translates to:
  /// **'+ Nouvelle'**
  String get newCategoryShort;

  /// No description provided for @optional.
  ///
  /// In fr, this message translates to:
  /// **'optionnel'**
  String get optional;

  /// No description provided for @addNote.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une note...'**
  String get addNote;

  /// No description provided for @update.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour'**
  String get update;

  /// No description provided for @selectCategory.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner une catégorie'**
  String get selectCategory;

  /// No description provided for @transactionUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Transaction mise à jour'**
  String get transactionUpdated;

  /// No description provided for @transactionAdded.
  ///
  /// In fr, this message translates to:
  /// **'Transaction ajoutée'**
  String get transactionAdded;

  /// No description provided for @somethingWentWrong.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur s\'est produite'**
  String get somethingWentWrong;

  /// No description provided for @trends.
  ///
  /// In fr, this message translates to:
  /// **'Tendances'**
  String get trends;

  /// No description provided for @noDataAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée disponible pour cette période'**
  String get noDataAvailable;

  /// No description provided for @loginToManage.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour gérer vos finances'**
  String get loginToManage;

  /// No description provided for @enterEmail.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre email'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un email valide'**
  String get enterValidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre mot de passe'**
  String get enterPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit faire au moins 6 caractères'**
  String get passwordTooShort;

  /// No description provided for @noAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ? '**
  String get noAccount;

  /// No description provided for @firstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de famille'**
  String get lastName;

  /// No description provided for @username.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get username;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà un compte ? '**
  String get alreadyHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccount;

  /// No description provided for @joiningMony.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez Mony pour mieux gérer votre argent'**
  String get joiningMony;

  /// No description provided for @profileSaved.
  ///
  /// In fr, this message translates to:
  /// **'Profil sauvegardé avec succès !'**
  String get profileSaved;

  /// No description provided for @errorSavingProfile.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la sauvegarde du profil'**
  String get errorSavingProfile;

  /// No description provided for @noProfileCalculated.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : Aucun profil calculé'**
  String get noProfileCalculated;

  /// No description provided for @noProfileToSave.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : Aucun profil à sauvegarder'**
  String get noProfileToSave;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @noQuestions.
  ///
  /// In fr, this message translates to:
  /// **'Aucune question disponible'**
  String get noQuestions;

  /// No description provided for @finish.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get finish;

  /// No description provided for @newBudget.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau budget'**
  String get newBudget;

  /// No description provided for @deleteBudget.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le budget'**
  String get deleteBudget;

  /// No description provided for @budgetDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Budget supprimé'**
  String get budgetDeleted;

  /// No description provided for @cannotDeleteDefaultCategory.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de supprimer une catégorie par défaut'**
  String get cannotDeleteDefaultCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la catégorie'**
  String get deleteCategory;

  /// No description provided for @confirmDelete.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la suppression'**
  String get confirmDelete;

  /// No description provided for @saveChanges.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get saveChanges;

  /// No description provided for @enterValidAmount.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un montant valide'**
  String get enterValidAmount;

  /// No description provided for @apply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get apply;

  /// No description provided for @all.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get all;

  /// No description provided for @loadingTransactions.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des transactions...'**
  String get loadingTransactions;

  /// No description provided for @noTransactionsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les transactions apparaîtront ici'**
  String get noTransactionsSubtitle;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Recherche'**
  String get search;

  /// No description provided for @filters.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filters;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In fr, this message translates to:
  /// **'Cette année'**
  String get thisYear;

  /// No description provided for @customPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Période personnalisée'**
  String get customPeriod;

  /// No description provided for @startDate.
  ///
  /// In fr, this message translates to:
  /// **'Date début'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In fr, this message translates to:
  /// **'Date fin'**
  String get endDate;

  /// No description provided for @editTransaction.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la transaction'**
  String get editTransaction;

  /// No description provided for @irreversible.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.'**
  String get irreversible;

  /// No description provided for @select.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez'**
  String get select;

  /// No description provided for @personalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get personalInfo;

  /// No description provided for @financialProfileSection.
  ///
  /// In fr, this message translates to:
  /// **'Profil Financier'**
  String get financialProfileSection;

  /// No description provided for @detailedAnalysis.
  ///
  /// In fr, this message translates to:
  /// **'Analyse détaillée'**
  String get detailedAnalysis;

  /// No description provided for @retakeQuestionnaire.
  ///
  /// In fr, this message translates to:
  /// **'Refaire le questionnaire'**
  String get retakeQuestionnaire;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Le nom ne peut pas être vide'**
  String get nameCannotBeEmpty;

  /// No description provided for @nameUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Nom mis à jour avec succès'**
  String get nameUpdated;

  /// No description provided for @confirmLogout.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir vous déconnecter ?'**
  String get confirmLogout;

  /// No description provided for @dailyReminders.
  ///
  /// In fr, this message translates to:
  /// **'Rappels quotidiens'**
  String get dailyReminders;

  /// No description provided for @dailyRemindersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Notification à 9h chaque jour'**
  String get dailyRemindersSubtitle;

  /// No description provided for @pdfOrExcel.
  ///
  /// In fr, this message translates to:
  /// **'PDF or Excel'**
  String get pdfOrExcel;

  /// No description provided for @resetSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer toutes les données'**
  String get resetSubtitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Version 2.0.0'**
  String get aboutSubtitle;

  /// No description provided for @aboutDescription.
  ///
  /// In fr, this message translates to:
  /// **'Une application moderne de gestion financière.'**
  String get aboutDescription;

  /// No description provided for @developedBy.
  ///
  /// In fr, this message translates to:
  /// **'Développée par Mohamed Farid'**
  String get developedBy;

  /// No description provided for @cannotOpenMail.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir l\'application mail'**
  String get cannotOpenMail;

  /// No description provided for @memberSince.
  ///
  /// In fr, this message translates to:
  /// **'Membre depuis {date}'**
  String memberSince(Object date);

  /// No description provided for @confidence.
  ///
  /// In fr, this message translates to:
  /// **'Confiance : {score}%'**
  String confidence(Object score);

  /// No description provided for @impulsivity.
  ///
  /// In fr, this message translates to:
  /// **'Impulsivité'**
  String get impulsivity;

  /// No description provided for @discipline.
  ///
  /// In fr, this message translates to:
  /// **'Discipline'**
  String get discipline;

  /// No description provided for @savingCapacity.
  ///
  /// In fr, this message translates to:
  /// **'Capacité d\'épargne'**
  String get savingCapacity;

  /// No description provided for @emotionalControl.
  ///
  /// In fr, this message translates to:
  /// **'Contrôle émotionnel'**
  String get emotionalControl;

  /// No description provided for @organizationLevel.
  ///
  /// In fr, this message translates to:
  /// **'Organisation'**
  String get organizationLevel;

  /// No description provided for @riskTolerance.
  ///
  /// In fr, this message translates to:
  /// **'Tolérance au risque'**
  String get riskTolerance;

  /// No description provided for @impulsiveSpenderLabel.
  ///
  /// In fr, this message translates to:
  /// **'Dépensier Impulsif'**
  String get impulsiveSpenderLabel;

  /// No description provided for @balancedAwareLabel.
  ///
  /// In fr, this message translates to:
  /// **'Équilibré Conscient'**
  String get balancedAwareLabel;

  /// No description provided for @strategicSaverLabel.
  ///
  /// In fr, this message translates to:
  /// **'Économe Stratégique'**
  String get strategicSaverLabel;

  /// No description provided for @overControllerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sur-contrôleur'**
  String get overControllerLabel;

  /// No description provided for @financiallyDisorganizedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Désorganisé Financier'**
  String get financiallyDisorganizedLabel;

  /// No description provided for @cautiousOptimizerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prudent Optimisateur'**
  String get cautiousOptimizerLabel;

  /// No description provided for @noCategories.
  ///
  /// In fr, this message translates to:
  /// **'Aucune catégorie'**
  String get noCategories;

  /// No description provided for @startByAddingCategory.
  ///
  /// In fr, this message translates to:
  /// **'Commencez par ajouter une catégorie'**
  String get startByAddingCategory;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @categoryDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie supprimée'**
  String get categoryDeleted;

  /// No description provided for @categoryDeleteError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la suppression'**
  String get categoryDeleteError;

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer \"{name}\" ?\n\nLes transactions associées ne seront pas supprimées.'**
  String confirmDeleteCategory(Object name);

  /// No description provided for @defaultLabel.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut'**
  String get defaultLabel;

  /// No description provided for @incomeTab.
  ///
  /// In fr, this message translates to:
  /// **'Revenus'**
  String get incomeTab;

  /// No description provided for @expensesTab.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses'**
  String get expensesTab;

  /// No description provided for @categoryNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la catégorie'**
  String get categoryNameLabel;

  /// No description provided for @categoryNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Courses, Restaurant...'**
  String get categoryNameHint;

  /// No description provided for @categoryNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est requis'**
  String get categoryNameRequired;

  /// No description provided for @categoryNameMinLength.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 2 caractères'**
  String get categoryNameMinLength;

  /// No description provided for @iconLabel.
  ///
  /// In fr, this message translates to:
  /// **'Icône'**
  String get iconLabel;

  /// No description provided for @colorLabel.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get colorLabel;

  /// No description provided for @categoryUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie mise à jour'**
  String get categoryUpdated;

  /// No description provided for @categoryCreated.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie créée'**
  String get categoryCreated;

  /// No description provided for @selectPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get selectPeriod;

  /// No description provided for @monthly.
  ///
  /// In fr, this message translates to:
  /// **'Mensuel'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In fr, this message translates to:
  /// **'Annuel'**
  String get yearly;

  /// No description provided for @amountHint.
  ///
  /// In fr, this message translates to:
  /// **'Montant du budget'**
  String get amountHint;

  /// No description provided for @selectCategoryRequired.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez une catégorie'**
  String get selectCategoryRequired;

  /// No description provided for @budgetUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Budget mis à jour'**
  String get budgetUpdated;

  /// No description provided for @budgetCreated.
  ///
  /// In fr, this message translates to:
  /// **'Budget créé'**
  String get budgetCreated;
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
      <String>['en', 'fr'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
