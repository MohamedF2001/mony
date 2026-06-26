// lib/core/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:mony/features/auth/presentation/screens/login_screen.dart';
import 'package:mony/features/auth/presentation/screens/register_screen.dart';
import 'package:mony/features/home/presentation/screens/splash_screen.dart';
import 'package:mony/features/transaction/presentation/screens/transaction_list_sreen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/main_navigation_screen.dart';
import '../../features/transaction/presentation/screens/add_transaction_screen.dart';
import '../../features/category/presentation/screens/category_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/budget/presentation/screens/budget_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/financial_profile/presentation/screens/questionnaire_screen.dart';
import '../../features/settings/presentation/screens/initial_settings_screen.dart';
import '../../features/premium/presentation/screens/premium_screen.dart';
import '../../features/coaching/presentation/screens/coach_ai_screen.dart';
import '../../features/coaching/presentation/screens/monthly_report_screen.dart';
import '../../features/insights/presentation/screens/simulation_screen.dart';
import '../../features/insights/presentation/screens/scenarios_screen.dart';
import '../../features/academy/presentation/screens/academy_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String initialSettings = '/initial-settings';
  static const String login = '/login';
  static const String register = '/register';
  static const String setupProfile = '/setup-profile';
  static const String questionnaire = '/questionnaire';
  static const String home = '/home';
  static const String addTransaction = '/add-transaction';
  static const String transactionList = '/transaction-list';
  static const String categories = '/categories';
  static const String statistics = '/statistics';
  static const String budgets = '/budgets';
  static const String settings = '/settings';
  
  // Premium Routes
  static const String premium = '/premium';
  static const String coachAi = '/coach-ai';
  static const String monthlyReport = '/monthly-report';
  static const String simulation = '/simulation';
  static const String scenarios = '/scenarios';
  static const String academy = '/academy';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingScreen(),
        initialSettings: (context) => const InitialSettingsScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        questionnaire: (context) => const QuestionnaireScreen(),
        home: (context) => const MainNavigationScreen(),
        addTransaction: (context) => const AddTransactionScreen(),
        transactionList: (context) => const TransactionListScreen(),
        categories: (context) => const CategoryScreen(),
        statistics: (context) => const StatisticsScreen(),
        budgets: (context) => const BudgetScreen(),
        settings: (context) => const SettingsScreen(),
        
        // Premium
        premium: (context) => const PremiumScreen(),
        coachAi: (context) => const CoachAIScreen(),
        monthlyReport: (context) => const MonthlyReportScreen(),
        simulation: (context) => const SimulationScreen(),
        scenarios: (context) => const ScenariosScreen(),
        academy: (context) => const AcademyScreen(),
      };
}
