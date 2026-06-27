// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Mony';

  @override
  String get welcome => 'Bienvenue sur Mony';

  @override
  String get welcomeDescription =>
      'Prenez le contrôle total de vos finances personnelles avec une application simple et puissante.';

  @override
  String get trackExpenses => 'Suivez vos dépenses';

  @override
  String get trackExpensesDescription =>
      'Enregistrez toutes vos transactions en quelques secondes et visualisez où va votre argent.';

  @override
  String get manageBudgets => 'Gérez vos budgets';

  @override
  String get manageBudgetsDescription =>
      'Créez des budgets mensuels pour chaque catégorie et recevez des alertes en temps réel.';

  @override
  String get analyzeFinances => 'Analysez vos finances';

  @override
  String get analyzeFinancesDescription =>
      'Obtenez des rapports détaillés et des graphiques pour comprendre vos habitudes financières.';

  @override
  String get aiAssistant => 'Assistant IA personnalisé';

  @override
  String get aiAssistantDescription =>
      'Recevez des conseils adaptés à votre profil financier';

  @override
  String get start => 'Commencer';

  @override
  String get next => 'Suivant';

  @override
  String get back => 'Précédent';

  @override
  String get skip => 'Passer';

  @override
  String get languageAndCurrency => 'Langue & Devise';

  @override
  String get chooseLanguageAndCurrency =>
      'Choisissez votre langue et votre devise préférées';

  @override
  String get language => 'Langue';

  @override
  String get currency => 'Devise';

  @override
  String get french => 'Français';

  @override
  String get english => 'Anglais';

  @override
  String get settings => 'Paramètres';

  @override
  String get profile => 'Profil';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get account => 'Compte';

  @override
  String get application => 'Application';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get notifications => 'Notifications';

  @override
  String get data => 'Données';

  @override
  String get exportData => 'Exporter les données';

  @override
  String get backup => 'Sauvegarde';

  @override
  String get restore => 'Restaurer';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get resetAllData => 'Réinitialiser toutes les données';

  @override
  String get support => 'Support';

  @override
  String get helpCenter => 'Centre d\'aide';

  @override
  String get sendFeedback => 'Envoyer un feedback';

  @override
  String get reportBug => 'Signaler un bug';

  @override
  String get rateApp => 'Évaluer l\'application';

  @override
  String get about => 'À propos';

  @override
  String get aboutMony => 'À propos de Mony';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get warning => 'Attention';

  @override
  String get irreversibleAction => 'Cette action est irréversible !';

  @override
  String get resetConfirmation =>
      'Cette action supprimera définitivement toutes vos données : transactions, catégories, budgets et paramètres.';

  @override
  String get dataReset => 'Données réinitialisées';

  @override
  String get error => 'Erreur';

  @override
  String get profileUpdated => 'Profil mis à jour';

  @override
  String get name => 'Nom';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'S\'inscrire';

  @override
  String get categories => 'Catégories';

  @override
  String get newCategory => 'Nouvelle catégorie';

  @override
  String get editCategory => 'Modifier la catégorie';

  @override
  String get budgets => 'Budgets';

  @override
  String get statistics => 'Statistiques';

  @override
  String get transactions => 'Transactions';

  @override
  String get addTransaction => 'Ajouter une transaction';

  @override
  String get totalBalance => 'Solde total';

  @override
  String get income => 'Revenu';

  @override
  String get expenses => 'Dépense';

  @override
  String get recentTransactions => 'Transactions récentes';

  @override
  String get seeAll => 'Voir tout';

  @override
  String hello(Object name) {
    return 'Bonjour $name 👋';
  }

  @override
  String get loading => 'Chargement...';

  @override
  String get noUser => 'Aucun utilisateur';

  @override
  String financialProfile(Object profile) {
    return 'Profil financier : $profile';
  }

  @override
  String youAreA(Object profile) {
    return 'Vous êtes un : $profile';
  }

  @override
  String get noTransaction => 'Aucune transaction';

  @override
  String get startByAddingTransaction =>
      'Commencez par ajouter votre première transaction';

  @override
  String get deleteTransaction => 'Supprimer la transaction';

  @override
  String get confirmDeleteTransaction =>
      'Êtes-vous sûr de vouloir supprimer cette transaction ?';

  @override
  String get transactionDeleted => 'Transaction supprimée';

  @override
  String get type => 'Type';

  @override
  String get description => 'Description';

  @override
  String get amount => 'Montant';

  @override
  String get date => 'Date';

  @override
  String get category => 'Catégorie';

  @override
  String get edit => 'Modifier';

  @override
  String get newTransaction => 'Nouvelle transaction';

  @override
  String get enterAmount => 'Entrez un montant';

  @override
  String get invalidAmount => 'Montant invalide';

  @override
  String get newCategoryShort => '+ Nouvelle';

  @override
  String get optional => 'optionnel';

  @override
  String get addNote => 'Ajouter une note...';

  @override
  String get update => 'Mettre à jour';

  @override
  String get selectCategory => 'Veuillez sélectionner une catégorie';

  @override
  String get transactionUpdated => 'Transaction mise à jour';

  @override
  String get transactionAdded => 'Transaction ajoutée';

  @override
  String get somethingWentWrong => 'Une erreur s\'est produite';

  @override
  String get trends => 'Tendances';

  @override
  String get noDataAvailable => 'Aucune donnée disponible pour cette période';

  @override
  String get loginToManage => 'Connectez-vous pour gérer vos finances';

  @override
  String get enterEmail => 'Veuillez entrer votre email';

  @override
  String get enterValidEmail => 'Veuillez entrer un email valide';

  @override
  String get enterPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit faire au moins 6 caractères';

  @override
  String get noAccount => 'Pas encore de compte ? ';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom de famille';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get joiningMony => 'Rejoignez Mony pour mieux gérer votre argent';

  @override
  String get profileSaved => 'Profil sauvegardé avec succès !';

  @override
  String get errorSavingProfile => 'Erreur lors de la sauvegarde du profil';

  @override
  String get noProfileCalculated => 'Erreur : Aucun profil calculé';

  @override
  String get noProfileToSave => 'Erreur : Aucun profil à sauvegarder';

  @override
  String get retry => 'Réessayer';

  @override
  String get noQuestions => 'Aucune question disponible';

  @override
  String get finish => 'Terminer';

  @override
  String get newBudget => 'Nouveau budget';

  @override
  String get deleteBudget => 'Supprimer le budget';

  @override
  String get budgetDeleted => 'Budget supprimé';

  @override
  String get cannotDeleteDefaultCategory =>
      'Impossible de supprimer une catégorie par défaut';

  @override
  String get deleteCategory => 'Supprimer la catégorie';

  @override
  String get confirmDelete => 'Confirmer la suppression';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get enterValidAmount => 'Veuillez entrer un montant valide';

  @override
  String get apply => 'Appliquer';

  @override
  String get all => 'Toutes';

  @override
  String get loadingTransactions => 'Chargement des transactions...';

  @override
  String get noTransactionsSubtitle => 'Les transactions apparaîtront ici';

  @override
  String get search => 'Recherche';

  @override
  String get filters => 'Filtres';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get thisMonth => 'Ce mois';

  @override
  String get thisYear => 'Cette année';

  @override
  String get customPeriod => 'Période personnalisée';

  @override
  String get startDate => 'Date début';

  @override
  String get endDate => 'Date fin';

  @override
  String get editTransaction => 'Modifier la transaction';

  @override
  String get irreversible => 'Cette action est irréversible.';

  @override
  String get select => 'Sélectionnez';

  @override
  String get personalInfo => 'Informations personnelles';

  @override
  String get financialProfileSection => 'Profil Financier';

  @override
  String get detailedAnalysis => 'Analyse détaillée';

  @override
  String get retakeQuestionnaire => 'Refaire le questionnaire';

  @override
  String get nameCannotBeEmpty => 'Le nom ne peut pas être vide';

  @override
  String get nameUpdated => 'Nom mis à jour avec succès';

  @override
  String get confirmLogout => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get dailyReminders => 'Rappels quotidiens';

  @override
  String get dailyRemindersSubtitle => 'Notification à 9h chaque jour';

  @override
  String get pdfOrExcel => 'PDF or Excel';

  @override
  String get resetSubtitle => 'Supprimer toutes les données';

  @override
  String get aboutSubtitle => 'Version 2.0.0';

  @override
  String get aboutDescription =>
      'Une application moderne de gestion financière.';

  @override
  String get developedBy => 'Développée par Mohamed Farid';

  @override
  String get cannotOpenMail => 'Impossible d\'ouvrir l\'application mail';

  @override
  String memberSince(Object date) {
    return 'Membre depuis $date';
  }

  @override
  String confidence(Object score) {
    return 'Confiance : $score%';
  }

  @override
  String get impulsivity => 'Impulsivité';

  @override
  String get discipline => 'Discipline';

  @override
  String get savingCapacity => 'Capacité d\'épargne';

  @override
  String get emotionalControl => 'Contrôle émotionnel';

  @override
  String get organizationLevel => 'Organisation';

  @override
  String get riskTolerance => 'Tolérance au risque';

  @override
  String get impulsiveSpenderLabel => 'Dépensier Impulsif';

  @override
  String get balancedAwareLabel => 'Équilibré Conscient';

  @override
  String get strategicSaverLabel => 'Économe Stratégique';

  @override
  String get overControllerLabel => 'Sur-contrôleur';

  @override
  String get financiallyDisorganizedLabel => 'Désorganisé Financier';

  @override
  String get cautiousOptimizerLabel => 'Prudent Optimisateur';

  @override
  String get noCategories => 'Aucune catégorie';

  @override
  String get startByAddingCategory => 'Commencez par ajouter une catégorie';

  @override
  String get add => 'Ajouter';

  @override
  String get categoryDeleted => 'Catégorie supprimée';

  @override
  String get categoryDeleteError => 'Erreur lors de la suppression';

  @override
  String confirmDeleteCategory(Object name) {
    return 'Êtes-vous sûr de vouloir supprimer \"$name\" ?\n\nLes transactions associées ne seront pas supprimées.';
  }

  @override
  String get defaultLabel => 'Par défaut';

  @override
  String get incomeTab => 'Revenus';

  @override
  String get expensesTab => 'Dépenses';

  @override
  String get categoryNameLabel => 'Nom de la catégorie';

  @override
  String get categoryNameHint => 'Ex: Courses, Restaurant...';

  @override
  String get categoryNameRequired => 'Le nom est requis';

  @override
  String get categoryNameMinLength => 'Minimum 2 caractères';

  @override
  String get iconLabel => 'Icône';

  @override
  String get colorLabel => 'Couleur';

  @override
  String get categoryUpdated => 'Catégorie mise à jour';

  @override
  String get categoryCreated => 'Catégorie créée';

  @override
  String get selectPeriod => 'Période';

  @override
  String get monthly => 'Mensuel';

  @override
  String get yearly => 'Annuel';

  @override
  String get amountHint => 'Montant du budget';

  @override
  String get selectCategoryRequired => 'Sélectionnez une catégorie';

  @override
  String get budgetUpdated => 'Budget mis à jour';

  @override
  String get budgetCreated => 'Budget créé';

  @override
  String get monyPremiumActive => 'Mony Premium Actif';

  @override
  String get discoverMonyPremium => 'Découvrir Mony Premium';

  @override
  String get premiumFeaturesSubtitle => 'Coach IA, Simulations, Académie...';

  @override
  String get premiumActiveSubtitle => 'Accédez à toutes vos fonctions avancées';

  @override
  String get subscriptionType => 'Type d\'abonnement';

  @override
  String premiumUntil(Object date) {
    return 'Premium jusqu\'au $date';
  }

  @override
  String get lifetimePlan => 'Plan à vie';

  @override
  String get exclusiveFeatures => 'Fonctions exclusives';

  @override
  String get coachAi => 'Coach IA';

  @override
  String get simulations => 'Simulations';

  @override
  String get monthlyReports => 'Rapports';

  @override
  String get academy => 'Académie';
}
