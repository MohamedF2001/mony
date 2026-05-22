// lib/features/profile/presentation/screens/user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mony/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/entities/user.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../category/presentation/providers/category_providers.dart';
import '../../../financial_profile/domain/entities/financial_profile.dart';
import '../../../financial_profile/domain/entities/financial_trait.dart';
import '../../../financial_profile/presentation/screens/questionnaire_screen.dart';
import '../../../settings/presentation/providers/app_reset_service_provider.dart';
import '../../../settings/presentation/providers/app_settings_provider.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditingName = false;
  bool _notificationsEnabled = false;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = ref.read(sharedPreferencesProvider).getBool('notifications_enabled') ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.nameCannotBeEmpty),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref
        .read(userProvider.notifier)
        .updateName(_nameController.text.trim());

    if (!mounted) return;

    setState(() => _isEditingName = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.nameUpdated),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.profile,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('${l10n.error}: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(userProvider.notifier).loadUser(),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (user) {
          if (user == null) {
            return Center(child: Text(l10n.noUser));
          }

          if (_nameController.text.isEmpty && !_isEditingName) {
            _nameController.text = user.name;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(user, settings.locale.languageCode),
                const SizedBox(height: 24),
                _buildPersonalInfoSection(user, l10n),
                const SizedBox(height: 16),
                if (user.hasFinancialProfile) ...[
                  _buildFinancialProfileSection(user, l10n),
                  const SizedBox(height: 16),
                ],
                _buildSettingsSection(settings, l10n),
                const SizedBox(height: 32),
                
                // Bouton de déconnexion
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      label: Text(
                        l10n.logout,
                        style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(User user, String languageCode) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.isEmpty ? l10n.noUser : user.name,
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.memberSince(_formatDate(user.createdAt, languageCode)),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(User user, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.personalInfo,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(
                  _isEditingName ? Icons.check : Icons.edit,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  if (_isEditingName) {
                    _updateName();
                  } else {
                    setState(() => _isEditingName = true);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isEditingName)
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.name,
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _updateName(),
            )
          else
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(l10n.name),
              subtitle: Text(
                user.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFinancialProfileSection(User user, AppLocalizations l10n) {
    final profile = user.financialProfile!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.financialProfileSection,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getColorForProfileType(profile.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getColorForProfileType(profile.type),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getIconForProfileType(profile.type),
                  color: _getColorForProfileType(profile.type),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getProfileLabel(profile.type, l10n),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getColorForProfileType(profile.type),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.confidence(profile.confidenceScore.toInt()),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ExpansionTile(
            title: Text(
              l10n.detailedAnalysis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: profile.traitScores.entries.map((entry) {
              final label = _getLabelForTrait(entry.key, l10n);
              final value = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${value.toInt()}/100',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: value / 100,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getColorForScore(value),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/questionnaire'),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retakeQuestionnaire),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(AppSettings settings, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildSection(
            title: l10n.notifications,
            children: [
              _buildSettingsTile(
                icon: Icons.notifications_outlined,
                title: l10n.dailyReminders,
                subtitle: l10n.dailyRemindersSubtitle,
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    final prefs = ref.read(sharedPreferencesProvider);
                    await prefs.setBool('notifications_enabled', value);
                    if (value) {
                      await NotificationService().scheduleDailyNotification();
                    } else {
                      await NotificationService().cancelAllNotifications();
                    }
                    setState(() => _notificationsEnabled = value);
                  },
                ),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: l10n.application,
            children: [
              _buildSettingsTile(
                icon: Icons.language,
                title: l10n.language,
                subtitle: settings.locale.languageCode == 'fr'
                    ? l10n.french
                    : l10n.english,
                onTap: _showLanguageDialog,
              ),
              _buildSettingsTile(
                icon: Icons.monetization_on_outlined,
                title: l10n.currency,
                subtitle: settings.currency,
                onTap: _showCurrencyDialog,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: l10n.data,
            children: [
              _buildSettingsTile(
                icon: Icons.file_download_outlined,
                title: l10n.exportData,
                subtitle: l10n.pdfOrExcel,
                onTap: _showExportDialog,
              ),
              _buildSettingsTile(
                icon: Icons.delete_outline,
                title: l10n.reset,
                subtitle: l10n.resetSubtitle,
                onTap: _confirmReset,
                trailing: const Icon(Icons.warning, color: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          _buildSection(
            title: l10n.about,
            children: [
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: l10n.aboutMony,
                subtitle: l10n.aboutSubtitle,
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
        ],
      ),
    );
  }

  String _formatDate(DateTime date, String languageCode) {
    if (languageCode == 'en') {
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } else {
      final months = [
        'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  Color _getColorForScore(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.blue;
    if (score >= 25) return Colors.orange;
    return Colors.red;
  }

  String _getLabelForTrait(FinancialTraitType type, AppLocalizations l10n) {
    switch (type) {
      case FinancialTraitType.impulsivity: return l10n.impulsivity;
      case FinancialTraitType.discipline: return l10n.discipline;
      case FinancialTraitType.savingCapacity: return l10n.savingCapacity;
      case FinancialTraitType.emotionalControl: return l10n.emotionalControl;
      case FinancialTraitType.organizationLevel: return l10n.organizationLevel;
      case FinancialTraitType.riskTolerance: return l10n.riskTolerance;
    }
  }

  String _getProfileLabel(ProfileType type, AppLocalizations l10n) {
    switch (type) {
      case ProfileType.impulsiveSpender: return l10n.impulsiveSpenderLabel;
      case ProfileType.balancedAware: return l10n.balancedAwareLabel;
      case ProfileType.strategicSaver: return l10n.strategicSaverLabel;
      case ProfileType.overController: return l10n.overControllerLabel;
      case ProfileType.financiallyDisorganized: return l10n.financiallyDisorganizedLabel;
      case ProfileType.cautiousOptimizer: return l10n.cautiousOptimizerLabel;
    }
  }

  Color _getColorForProfileType(ProfileType type) {
    switch (type) {
      case ProfileType.impulsiveSpender: return const Color(0xFFFF6B6B);
      case ProfileType.balancedAware: return const Color(0xFF4CAF50);
      case ProfileType.strategicSaver: return const Color(0xFF2196F3);
      case ProfileType.overController: return const Color(0xFF9C27B0);
      case ProfileType.financiallyDisorganized: return const Color(0xFFFF9800);
      case ProfileType.cautiousOptimizer: return const Color(0xFF00BCD4);
    }
  }

  IconData _getIconForProfileType(ProfileType type) {
    switch (type) {
      case ProfileType.impulsiveSpender: return Icons.shopping_bag;
      case ProfileType.balancedAware: return Icons.balance;
      case ProfileType.strategicSaver: return Icons.savings;
      case ProfileType.overController: return Icons.lock;
      case ProfileType.financiallyDisorganized: return Icons.shuffle;
      case ProfileType.cautiousOptimizer: return Icons.psychology;
    }
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
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
                    Text(title, style: AppTypography.textTheme.titleSmall),
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
                ref.read(appSettingsProvider.notifier).setLocale(const Locale('fr'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.english),
              onTap: () {
                ref.read(appSettingsProvider.notifier).setLocale(const Locale('en'));
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
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel'),
              onTap: () => Navigator.pop(context),
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
        title: Text('⚠️ ${l10n.warning}'),
        content: Text(
          '${l10n.resetConfirmation}\n\n${l10n.irreversibleAction}',
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
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(appResetServiceProvider).resetAll();
      ref.invalidate(transactionProvider);
      ref.invalidate(categoryProvider);
      ref.invalidate(budgetProvider);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dataReset),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const QuestionnaireScreen()),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> _sendFeedback() async {
    final l10n = AppLocalizations.of(context)!;
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'frdmoussiliou@gmail.com',
      query: 'subject=Feedback Mony App&body=',
    );
    if (!await launchUrl(emailUri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotOpenMail)),
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
        Text(l10n.aboutDescription),
        const SizedBox(height: 8),
        Text(l10n.developedBy),
      ],
    );
  }
}
