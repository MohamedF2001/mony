import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'core/models/user_model_adapter.dart';
import 'core/routes/app_routes.dart';
import 'core/services/notification_service.dart';
import 'features/budget/data/models/budget_model.dart';
import 'features/budget/data/models/budget_model_adapter.dart';
import 'features/category/data/models/category_model.dart';
import 'features/category/data/models/category_model_adapter.dart';
import 'features/financial_profile/data/models/profile_model.dart';
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

  // Init date formatting
  await initializeDateFormatting('fr_FR', null);

  // Init Hive
  await Hive.initFlutter();

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
    Hive.openBox<FinancialProfileModel>('financial_profiles'),
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

  // 🔥 INITIALISATION DES NOTIFICATIONS EN ARRIÈRE-PLAN
  _initNotificationsAsync();

  runApp(const ProviderScope(child: MyApp()));
}

// ✅ Fonction asynchrone qui ne bloque pas le lancement
Future<void> _initNotificationsAsync() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

    if (notificationsEnabled) {
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.scheduleDailyNotification();
    }
  } catch (e) {
    debugPrint('❌ Erreur initialisation notifications: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mony',
      theme: ThemeData(
        primaryColor: const Color(0xFF2D6CFF),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D6CFF)),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/questionnaire': (context) => const QuestionnaireScreen(),
        '/name-input': (context) => const NameInputScreen(),
        '/profile': (context) => const UserProfileScreen(),
        '/home': (context) => const MainNavigationScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
