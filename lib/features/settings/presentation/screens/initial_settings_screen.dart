// lib/features/settings/presentation/screens/initial_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mony/l10n/app_localizations.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/services/user_service.dart';
import '../providers/app_settings_provider.dart';

class InitialSettingsScreen extends ConsumerWidget {
  const InitialSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.language,
                  size: 80,
                  color: Color(0xFFFF9800),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                l10n.languageAndCurrency,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.chooseLanguageAndCurrency,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildSelectionTile(
                context,
                title: l10n.language,
                value: settings.locale.languageCode == 'fr'
                    ? l10n.french
                    : l10n.english,
                onTap: () => _showLanguageDialog(context, ref),
              ),
              const SizedBox(height: 16),
              _buildSelectionTile(
                context,
                title: l10n.currency,
                value: settings.currency,
                onTap: () => _showCurrencyDialog(context, ref),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(appSettingsProvider.notifier).markPreferencesAsSet();
                    if (!context.mounted) return;

                    final navigationService = NavigationService(UserService());
                    final route = await navigationService.getInitialRoute();
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(context, route);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.start,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionTile(
    BuildContext context, {
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

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
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

  void _showCurrencyDialog(BuildContext context, WidgetRef ref) {
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
