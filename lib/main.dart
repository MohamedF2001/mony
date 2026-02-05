import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/models/user_model_adapter.dart';
import 'core/routes/app_routes.dart';
import 'core/screens/app_router.dart';
import 'features/budget/data/models/budget_model.dart';
import 'features/budget/data/models/budget_model_adapter.dart';
import 'features/category/data/models/category_model.dart';
import 'features/category/data/models/category_model_adapter.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/financial_profile/data/models/answer_model_adapter.dart';
import 'features/financial_profile/data/models/profile_model_adapter.dart';
import 'features/financial_profile/data/models/question_model_adapter.dart';
import 'features/financial_profile/presentation/screens/questionnaire_screen.dart';
import 'features/home/presentation/screens/main_navigation_screen.dart';
import 'features/home/presentation/screens/splash_screen.dart';
import 'features/onboarding/presentation/screens/name_input_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/profile/presentation/screens/user_profile_screen.dart';
import 'features/transaction/data/models/transaction_model.dart';
import 'features/transaction/data/models/transaction_model_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //await Hive.deleteFromDisk();

  // Init date formatting
  await initializeDateFormatting('fr_FR', null);

  // Init Hive
  await Hive.initFlutter();

  // Delete ALL Hive data (only during development)
  //await Hive.deleteFromDisk();

  // Register adapters
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(QuestionModelAdapter());
  Hive.registerAdapter(AnswerChoiceModelAdapter());
  Hive.registerAdapter(AnswerModelAdapter());
  Hive.registerAdapter(FinancialProfileModelAdapter());
  Hive.registerAdapter(UserModelAdapter());

  // Open boxes safely
  await Future.wait([
    Hive.openBox<TransactionModel>('transactions'),
    Hive.openBox<CategoryModel>('categories'),
    Hive.openBox<BudgetModel>('budgets'),
    Hive.openBox('storage'),
  ]);

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['GEMINI_API_KEY']!;
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mony',
      theme: ThemeData(
        primaryColor: const Color(0xFF2D6CFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6CFF),
        ),
        useMaterial3: true,
      ),
      // ✨ NOUVEAU : Router automatique
      /*home: AppRouter(
        dashboardScreen: DashboardScreen(), // Votre dashboard
      ),
      // Routes nommées (optionnel)
      routes: {
        '/dashboard': (context) => DashboardScreen(),
        '/profile': (context) => const UserProfileScreen(),
      },*/
      initialRoute: AppRoutes.splash,

      // Définition de toutes les routes
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/questionnaire': (context) => const QuestionnaireScreen(),
        '/name-input': (context) => const NameInputScreen(),
        '/profile': (context) => const UserProfileScreen(),
        // TODO: Ajoutez votre route home
        '/home': (context) => const MainNavigationScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/models/user_model_adapter.dart';
import 'core/screens/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/budget/data/models/budget_model_adapter.dart';
import 'features/category/data/models/category_model_adapter.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/financial_profile/data/models/answer_model.dart';
import 'features/financial_profile/data/models/answer_model_adapter.dart';
import 'features/financial_profile/data/models/profile_model.dart';
import 'features/financial_profile/data/models/profile_model_adapter.dart';
import 'features/financial_profile/data/models/question_model.dart';
import 'features/financial_profile/data/models/question_model_adapter.dart';
import 'features/financial_profile/presentation/screens/questionnaire_screen.dart';
import 'features/profile/presentation/screens/user_profile_screen.dart';
import 'features/transaction/data/models/transaction_model.dart';
import 'features/category/data/models/category_model.dart';
import 'features/budget/data/models/budget_model.dart';
import 'core/routes/app_routes.dart';
import 'features/transaction/data/models/transaction_model_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //await Hive.deleteFromDisk();

  // Init date formatting
  await initializeDateFormatting('fr_FR', null);

  // Init Hive
  await Hive.initFlutter();

  // Delete ALL Hive data (only during development)
  //await Hive.deleteFromDisk();

  // Register adapters
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(QuestionModelAdapter());
  Hive.registerAdapter(AnswerChoiceModelAdapter());
  Hive.registerAdapter(AnswerModelAdapter());
  Hive.registerAdapter(FinancialProfileModelAdapter());
  Hive.registerAdapter(UserModelAdapter());

  // Open boxes safely
  await Future.wait([
    Hive.openBox<TransactionModel>('transactions'),
    Hive.openBox<CategoryModel>('categories'),
    Hive.openBox<BudgetModel>('budgets'),
    Hive.openBox('storage'),
  ]);

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['GEMINI_API_KEY']!;
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return MaterialApp(
      title: 'Mony',
      theme: ThemeData(
        primaryColor: const Color(0xFF2D6CFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6CFF),
        ),
        useMaterial3: true,
      ),
      // ✨ NOUVEAU : Router automatique
      home: AppRouter(
        dashboardScreen: DashboardScreen(), // Votre dashboard
      ),
      // Routes nommées (optionnel)
      routes: {
        '/dashboard': (context) => DashboardScreen(),
        '/profile': (context) => const UserProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );

    *//*return MaterialApp(
      title: 'Mony - Money Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );*//*

    *//*return MaterialApp(
      title: 'Mony',
      theme: ThemeData(
        primaryColor: const Color(0xFF2D6CFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6CFF),
        ),
      ),
      // Navigation initiale vers le questionnaire (nouveaux utilisateurs)
      home: const QuestionnaireScreen(),
    );*//*
  }
}*/

