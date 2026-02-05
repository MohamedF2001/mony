// lib/core/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:mony/features/home/presentation/screens/splash_screen.dart';
import 'package:mony/features/transaction/presentation/screens/transaction_list_sreen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/main_navigation_screen.dart';
import '../../features/transaction/presentation/screens/add_transaction_screen.dart';
import '../../features/category/presentation/screens/category_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/budget/presentation/screens/budget_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String setupProfile = '/setup-profile';
  static const String home = '/home';
  static const String addTransaction = '/add-transaction';
  static const String transactionList = '/transaction-list';
  static const String categories = '/categories';
  static const String statistics = '/statistics';
  static const String budgets = '/budgets';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingScreen(),
        //setupProfile: (context) =>  const ProfileSetupScreen(),
        home: (context) => const MainNavigationScreen(),
        addTransaction: (context) => const AddTransactionScreen(),
        transactionList: (context) => const TransactionListScreen(),
        categories: (context) => const CategoryScreen(),
        statistics: (context) => const StatisticsScreen(),
        budgets: (context) => const BudgetScreen(),
        settings: (context) => const SettingsScreen(),
      };
}