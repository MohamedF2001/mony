// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mony';

  @override
  String get welcome => 'Welcome to Mony';

  @override
  String get welcomeDescription =>
      'Take full control of your personal finances with a simple and powerful app.';

  @override
  String get trackExpenses => 'Track your expenses';

  @override
  String get trackExpensesDescription =>
      'Record all your transactions in seconds and visualize where your money goes.';

  @override
  String get manageBudgets => 'Manage your budgets';

  @override
  String get manageBudgetsDescription =>
      'Create monthly budgets for each category and receive real-time alerts.';

  @override
  String get analyzeFinances => 'Analyze your finances';

  @override
  String get analyzeFinancesDescription =>
      'Get detailed reports and charts to understand your financial habits.';

  @override
  String get aiAssistant => 'Personalized AI Assistant';

  @override
  String get aiAssistantDescription =>
      'Receive advice tailored to your financial profile';

  @override
  String get start => 'Start';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get languageAndCurrency => 'Language & Currency';

  @override
  String get chooseLanguageAndCurrency =>
      'Choose your preferred language and currency';

  @override
  String get language => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get french => 'French';

  @override
  String get english => 'English';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get account => 'Account';

  @override
  String get application => 'Application';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get data => 'Data';

  @override
  String get exportData => 'Export Data';

  @override
  String get backup => 'Backup';

  @override
  String get restore => 'Restore';

  @override
  String get reset => 'Reset';

  @override
  String get resetAllData => 'Reset All Data';

  @override
  String get support => 'Support';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get reportBug => 'Report a Bug';

  @override
  String get rateApp => 'Rate App';

  @override
  String get about => 'About';

  @override
  String get aboutMony => 'About Mony';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get logout => 'Logout';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get warning => 'Warning';

  @override
  String get irreversibleAction => 'This action is irreversible!';

  @override
  String get resetConfirmation =>
      'This action will permanently delete all your data: transactions, categories, budgets, and settings.';

  @override
  String get dataReset => 'Data reset';

  @override
  String get error => 'Error';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get categories => 'Categories';

  @override
  String get newCategory => 'New Category';

  @override
  String get budgets => 'Budgets';

  @override
  String get statistics => 'Statistics';

  @override
  String get transactions => 'Transactions';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expense';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get seeAll => 'See All';

  @override
  String hello(Object name) {
    return 'Hello $name 👋';
  }

  @override
  String get loading => 'Loading...';

  @override
  String get noUser => 'No user';

  @override
  String financialProfile(Object profile) {
    return 'Financial Profile: $profile';
  }

  @override
  String youAreA(Object profile) {
    return 'You are a: $profile';
  }

  @override
  String get noTransaction => 'No transaction';

  @override
  String get startByAddingTransaction =>
      'Start by adding your first transaction';

  @override
  String get deleteTransaction => 'Delete transaction';

  @override
  String get confirmDeleteTransaction =>
      'Are you sure you want to delete this transaction?';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get type => 'Type';

  @override
  String get description => 'Description';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get category => 'Category';

  @override
  String get edit => 'Edit';

  @override
  String get newTransaction => 'New transaction';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String get newCategoryShort => '+ New';

  @override
  String get optional => 'optional';

  @override
  String get addNote => 'Add a note...';

  @override
  String get update => 'Update';

  @override
  String get selectCategory => 'Please select a category';

  @override
  String get transactionUpdated => 'Transaction updated';

  @override
  String get transactionAdded => 'Transaction added';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get trends => 'Trends';

  @override
  String get noDataAvailable => 'No data available for this period';

  @override
  String get loginToManage => 'Log in to manage your finances';

  @override
  String get enterEmail => 'Please enter your email';

  @override
  String get enterValidEmail => 'Please enter a valid email';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get noAccount => 'Don\'t have an account yet? ';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get username => 'Username';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get createAccount => 'Create account';

  @override
  String get joiningMony => 'Join Mony to better manage your money';

  @override
  String get profileSaved => 'Profile saved successfully!';

  @override
  String get errorSavingProfile => 'Error saving profile';

  @override
  String get noProfileCalculated => 'Error: No profile calculated';

  @override
  String get noProfileToSave => 'Error: No profile to save';

  @override
  String get retry => 'Retry';

  @override
  String get noQuestions => 'No questions available';

  @override
  String get finish => 'Finish';

  @override
  String get newBudget => 'New budget';

  @override
  String get deleteBudget => 'Delete budget';

  @override
  String get budgetDeleted => 'Budget deleted';

  @override
  String get cannotDeleteDefaultCategory => 'Cannot delete a default category';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String get confirmDelete => 'Confirm delete';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get enterValidAmount => 'Please enter a valid amount';

  @override
  String get apply => 'Apply';

  @override
  String get all => 'All';

  @override
  String get loadingTransactions => 'Loading transactions...';

  @override
  String get noTransactionsSubtitle => 'Transactions will appear here';

  @override
  String get search => 'Search';

  @override
  String get filters => 'Filters';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisYear => 'This year';

  @override
  String get customPeriod => 'Custom period';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get editTransaction => 'Edit transaction';

  @override
  String get irreversible => 'This action is irreversible.';

  @override
  String get select => 'Select';
}
