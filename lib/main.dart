import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/models/user_model_adapter.dart';
import 'core/routes/app_routes.dart';
import 'core/screens/app_router.dart';
import 'core/services/notification_service.dart';
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

/*void main() async {
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

  final notificationService = NotificationService();
  await notificationService.initialize();

  // Programmer la notification quotidienne à 9h
  await notificationService.scheduleDailyNotification();

  final prefs = await SharedPreferences.getInstance();
  final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

  if (notificationsEnabled) {
    final service = NotificationService();
    await service.initialize();
    await service.scheduleDailyNotification();
  }

  runApp(
    const ProviderScope(child: MyApp()),
  );
}*/

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
  // Ne pas bloquer le lancement de l'app
  _initNotificationsAsync();

  runApp(const ProviderScope(child: MyAppp()));
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mony',
      theme: ThemeData(
        primaryColor: const Color(0xFF2D6CFF),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D6CFF)),
        useMaterial3: true,
      ),
      // ✨ NOUVEAU : Router automatique
      //home: NotificationDemoScreen(),
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

class MyAppp extends StatelessWidget {
  const MyAppp({super.key});

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
        '/questionnaire': (context) => const QuestionnaireScreen(),
        '/name-input': (context) => const NameInputScreen(),
        '/profile': (context) => const UserProfileScreen(),
        '/home': (context) => const MainNavigationScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotificationDemoScreen extends StatefulWidget {
  const NotificationDemoScreen({Key? key}) : super(key: key);

  @override
  State<NotificationDemoScreen> createState() => _NotificationDemoScreenState();
}

class _NotificationDemoScreenState extends State<NotificationDemoScreen> {
  final NotificationService _notificationService = NotificationService();
  List<PendingNotificationRequest> _pendingNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadPendingNotifications();
  }

  Future<void> _loadPendingNotifications() async {
    final notifications = await _notificationService.getPendingNotifications();
    setState(() {
      _pendingNotifications = notifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Quotidiennes'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête informatif
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.notifications_active,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Notification quotidienne programmée',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vous recevrez une notification tous les jours à 9h00',
                    style: TextStyle(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_pendingNotifications.length} notification(s) programmée(s)',
                      style: TextStyle(
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Boutons de contrôle
            const Text(
              'Actions de test',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 16),

            // Bouton test immédiat
            ElevatedButton.icon(
              onPressed: () async {
                await _notificationService.showTestNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Notification de test envoyée'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.notification_add),
              label: const Text('Tester maintenant'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            // Bouton reprogrammer
            OutlinedButton.icon(
              onPressed: () async {
                await _notificationService.scheduleDailyNotification();
                await _loadPendingNotifications();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Notification quotidienne reprogrammée'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reprogrammer à 9h'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            // Bouton annuler
            OutlinedButton.icon(
              onPressed: () async {
                await _notificationService.cancelAllNotifications();
                await _loadPendingNotifications();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Notifications annulées'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Annuler toutes les notifications'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                foregroundColor: Colors.red,
              ),
            ),

            const SizedBox(height: 12),

            // Bouton actualiser
            TextButton.icon(
              onPressed: _loadPendingNotifications,
              icon: const Icon(Icons.sync),
              label: const Text('Actualiser le statut'),
            ),

            const Spacer(),

            // Informations techniques
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ℹ️ Informations',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Fonctionne même si l\'app est fermée',
                    style: TextStyle(fontSize: 12),
                  ),
                  const Text(
                    '• Pas besoin de connexion internet',
                    style: TextStyle(fontSize: 12),
                  ),
                  const Text(
                    '• Notification quotidienne à 9h précises',
                    style: TextStyle(fontSize: 12),
                  ),
                  const Text(
                    '• Compatible Android 8+',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
