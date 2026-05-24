// lib/features/settings/presentation/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mony/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../financial_profile/presentation/screens/questionnaire_screen.dart';
import '../../../financial_profile/presentation/utils/financial_profile_ui_utils.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../../../category/presentation/providers/category_providers.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../providers/app_reset_service_provider.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/profil_header.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider);
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (user) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Header
            const ProfileHeader(),

            const SizedBox(height: 24),

            // Financial Profile Section
            if (user?.financialProfile != null) ...[
              _buildSection(
                title: l10n.financialProfileSection,
                children: [
                  _buildSettingsTile(
                    icon: FinancialProfileUIUtils.getIconForProfileType(user!.financialProfile!.type),
                    title: FinancialProfileUIUtils.getProfileLabel(user.financialProfile!.type, l10n),
                    subtitle: l10n.confidence(user.financialProfile!.confidenceScore.toInt()),
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                  _buildSettingsTile(
                    icon: Icons.refresh,
                    title: l10n.retakeQuestionnaire,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QuestionnaireScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // App Settings Section
            _buildSection(
              title: l10n.application,
              children: [
                _buildSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: l10n.darkMode,
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() => _isDarkMode = value);
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.language,
                  title: l10n.language,
                  subtitle: settings.locale.languageCode == 'fr'
                      ? l10n.french
                      : l10n.english,
                  onTap: () => _showLanguageDialog(),
                ),
                _buildSettingsTile(
                  icon: Icons.monetization_on_outlined,
                  title: l10n.currency,
                  subtitle: settings.currency,
                  onTap: () => _showCurrencyDialog(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Data Section
            _buildSection(
              title: l10n.data,
              children: [
                _buildSettingsTile(
                  icon: Icons.file_download_outlined,
                  title: l10n.exportData,
                  subtitle: 'PDF / Excel',
                  onTap: _showExportDialog,
                ),
                _buildSettingsTile(
                  icon: Icons.delete_outline,
                  title: l10n.reset,
                  subtitle: l10n.resetConfirmation,
                  onTap: _confirmReset,
                  trailing: const Icon(Icons.warning, color: AppColors.error),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Support Section
            _buildSection(
              title: l10n.support,
              children: [
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: l10n.helpCenter,
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.feedback_outlined,
                  title: l10n.sendFeedback,
                  onTap: _sendFeedback,
                ),
                _buildSettingsTile(
                  icon: Icons.bug_report_outlined,
                  title: l10n.reportBug,
                  onTap: _sendFeedback,
                ),
                _buildSettingsTile(
                  icon: Icons.star_outline,
                  title: l10n.rateApp,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // About Section
            _buildSection(
              title: l10n.about,
              children: [
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: l10n.aboutMony,
                  subtitle: 'Version 2.0.0',
                  onTap: _showAboutDialog,
                ),
                _buildSettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.privacyPolicy,
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.gavel,
                  title: l10n.termsOfService,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                onPressed: () {
                  // Logout logic already in UserProfileScreen or AuthProvider
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.logout),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.textTheme.titleSmall,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ?? const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTypography.textTheme.titleSmall,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
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

  void _showExportDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exportData),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.warning} ⚠️'),
        content: Text(
          '${l10n.resetConfirmation}\n\n'
          '${l10n.irreversibleAction}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetAllData();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllData() async {
    try {
      await ref.read(appResetServiceProvider).resetAll();

      ref.invalidate(transactionProvider);
      ref.invalidate(categoryProvider);
      ref.invalidate(budgetProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.dataReset)),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        return const QuestionnaireScreen();
      }));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _sendFeedback() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'frdmoussiliou@gmail.com',
      query: 'subject=Feedback Mony App&body=',
    );

    if (!await launchUrl(emailUri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir l\'application mail'),
        ),
      );
    }
  }

  void _showAboutDialog() {
    final l10n = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: 'Mony',
      applicationVersion: '2.0.0',
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset('assets/images/mony.jpg', width: 64),
      ),
      children: [
        const SizedBox(height: 16),
        Text(l10n.welcomeDescription),
        const SizedBox(height: 8),
        const Text('Développée par Mohamed Farid'),
      ],
    );
  }
}
