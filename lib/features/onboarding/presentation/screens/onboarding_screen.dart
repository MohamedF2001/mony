import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:mony/l10n/app_localizations.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../settings/presentation/providers/app_settings_provider.dart';

/// Écran d'onboarding
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingPageData> _getPages(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      OnboardingPageData(
        title: l10n.languageAndCurrency,
        description: l10n.chooseLanguageAndCurrency,
        lottieAsset: 'assets/lotties/l.json',
        icon: Icons.language,
        color: const Color(0xFFFF9800),
        isSettingsPage: true,
      ),
      OnboardingPageData(
        title: l10n.welcome,
        description: l10n.welcomeDescription,
        lottieAsset: 'assets/lotties/un.json',
        icon: Icons.account_balance_wallet,
        color: const Color(0xFF2D6CFF),
      ),
      OnboardingPageData(
        title: l10n.trackExpenses,
        description: l10n.trackExpensesDescription,
        lottieAsset: 'assets/lotties/de.json',
        icon: Icons.analytics,
        color: const Color(0xFF00D09C),
      ),
      OnboardingPageData(
        title: l10n.manageBudgets,
        description: l10n.manageBudgetsDescription,
        lottieAsset: 'assets/lotties/deux.json',
        icon: Icons.trending_up,
        color: const Color(0xFFFF6B6B),
      ),
      OnboardingPageData(
        title: l10n.analyzeFinances,
        description: l10n.analyzeFinancesDescription,
        lottieAsset: 'assets/lotties/finance.json',
        icon: Icons.psychology,
        color: const Color(0xFF9C27B0),
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final navigationService = NavigationService(UserService());

    // Mark preferences as set when completing onboarding
    await ref.read(appSettingsProvider.notifier).markPreferencesAsSet();

    // CRITICAL: Save that onboarding has been seen
    await navigationService.markOnboardingAsSeen();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _getPages(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _currentPage == pages.length - 1
                    ? null
                    : () {
                        _pageController.animateToPage(
                          pages.length - 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                child: Text(
                  l10n.skip,
                  style: TextStyle(
                    color: _currentPage == pages.length - 1
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(pages[index]);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == pages.length - 1) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == pages.length - 1 ? l10n.start : l10n.next,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPageData page) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider);

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (page.lottieAsset != null)
            Lottie.asset(
              page.lottieAsset!,
              height: 200,
              repeat: true,
              reverse: false,
              animate: true,
            )
          else if (page.image != null)
            Image.asset(
              page.image!,
              height: 200,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: page.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: page.color,
                ),
              ),
            )
          else
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: page.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                page.icon,
                size: 80,
                color: page.color,
              ),
            ),
          const SizedBox(height: 20),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          if (page.isSettingsPage) ...[
            Text(
              page.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            _buildSelectionTile(
              title: l10n.language,
              value: settings.locale.languageCode == 'fr'
                  ? l10n.french
                  : l10n.english,
              onTap: () => _showLanguageDialog(),
            ),
            const SizedBox(height: 10),
            _buildSelectionTile(
              title: l10n.currency,
              value: settings.currency,
              onTap: () => _showCurrencyDialog(),
            ),
          ] else
            Text(
              page.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildSelectionTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.french),
              onTap: () {
                ref
                    .read(appSettingsProvider.notifier)
                    .setLocale(const Locale('fr'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.english),
              onTap: () {
                ref
                    .read(appSettingsProvider.notifier)
                    .setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.currency),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('F CFA'),
              onTap: () {
                ref.read(appSettingsProvider.notifier).setCurrency('F CFA');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('\$'),
              onTap: () {
                ref.read(appSettingsProvider.notifier).setCurrency('\$');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('€'),
              onTap: () {
                ref.read(appSettingsProvider.notifier).setCurrency('€');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String description;
  final String? image;
  final String? lottieAsset;
  final IconData? icon;
  final Color color;
  final bool isSettingsPage;

  OnboardingPageData({
    required this.title,
    required this.description,
    this.image,
    this.lottieAsset,
    this.icon,
    required this.color,
    this.isSettingsPage = false,
  });
}
