// lib/features/settings/presentation/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
//import '../../../../screens/onboard/on_board.dart';
import '../../../financial_profile/presentation/screens/questionnaire_screen.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../../../category/presentation/providers/category_providers.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../providers/app_reset_service_provider.dart';
import '../widgets/profil_header.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          const ProfileHeader(),

          const SizedBox(height: 24),

          // Account Section
          /*_buildSection(
            title: 'Compte',
            children: [
              _buildSettingsTile(
                icon: Icons.person_outline,
                title: 'Profil',
                subtitle: 'Gérer vos informations personnelles',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileEditScreen(),
                    ),
                  );
                },
              ),
              *//*_buildSettingsTile(
                icon: Icons.security,
                title: 'Sécurité',
                subtitle: 'Mot de passe et authentification',
                onTap: () {},
              ),*//*
            ],
          ),

          const SizedBox(height: 24),*/

          // App Settings Section
          _buildSection(
            title: 'Application',
            children: [
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: 'Mode sombre',
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() => _isDarkMode = value);
                },
              ),
              /*_buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),*/
              _buildSettingsTile(
                icon: Icons.language,
                title: 'Langue',
                subtitle: 'Français',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Data Section
          _buildSection(
            title: 'Données',
            children: [
              _buildSettingsTile(
                icon: Icons.file_download_outlined,
                title: 'Exporter les données',
                subtitle: 'PDF ou Excel',
                onTap: _showExportDialog,
              ),
              _buildSettingsTile(
                icon: Icons.backup_outlined,
                title: 'Sauvegarde',
                subtitle: 'Sauvegarder vos données',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.restore,
                title: 'Restaurer',
                subtitle: 'Importer des données',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.delete_outline,
                title: 'Réinitialiser',
                subtitle: 'Supprimer toutes les données',
                onTap: _confirmReset,
                trailing: const Icon(Icons.warning, color: AppColors.error),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Support Section
          _buildSection(
            title: 'Support',
            children: [
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Centre d\'aide',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.feedback_outlined,
                title: 'Envoyer un feedback',
                onTap: _sendFeedback,
              ),
              _buildSettingsTile(
                icon: Icons.bug_report_outlined,
                title: 'Signaler un bug',
                onTap: _sendFeedback,
              ),
              _buildSettingsTile(
                icon: Icons.star_outline,
                title: 'Évaluer l\'application',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSection(
            title: 'À propos',
            children: [
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'À propos de Mony',
                subtitle: 'Version 2.0.0',
                onTap: _showAboutDialog,
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Politique de confidentialité',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.gavel,
                title: 'Conditions d\'utilisation',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Se déconnecter'),
            ),
          ),

          const SizedBox(height: 32),
        ],
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

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exporter les données'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Exporter en PDF'),
              onTap: () {
                Navigator.pop(context);
                // Export to PDF
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Exporter en Excel'),
              onTap: () {
                Navigator.pop(context);
                // Export to Excel
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Attention'),
        content: const Text(
          'Cette action supprimera définitivement toutes vos données : '
          'transactions, catégories, budgets et paramètres.\n\n'
          'Cette action est irréversible !',
        ),
        actions: [
          TextButton(
            style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetAllData();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  /*Future<void> _resetAllData() async {
    try {
      // Clear all Hive boxes
      await Hive.box('transactions').clear();
      await Hive.box('categories').clear();
      await Hive.box('budgets').clear();
      await Hive.box('storage').clear();

      // Refresh providers
      ref.invalidate(transactionProvider);
      ref.invalidate(categoryProvider);
      ref.invalidate(budgetProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Données réinitialisées'),
          backgroundColor: AppColors.success,
        ),
      );

      // Restart app or navigate to onboarding
    } catch (e) {
      if (!mounted) return;
      print('Erreur lors de la réinitialisation des données: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }*/

  Future<void> _resetAllData() async {
    try {
      await ref.read(appResetServiceProvider).resetAll();

      ref.invalidate(transactionProvider);
      ref.invalidate(categoryProvider);
      ref.invalidate(budgetProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Données réinitialisées')),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        return const QuestionnaireScreen();
        //return const OnboardingScreen();
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
        const Text('Une application moderne de gestion financière.'),
        const SizedBox(height: 8),
        const Text('Développée par Mohamed Farid'),
      ],
    );
  }
}

// Profile Edit Screen
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final storageBox = Hive.box('storage');

  @override
  void initState() {
    super.initState();
    _nameController.text = storageBox.get('userName', defaultValue: '');
    _emailController.text = storageBox.get('userEmail', defaultValue: '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Avatar
          Center(
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.white,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nom',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),

          const SizedBox(height: 16),

          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),

          /*const SizedBox(height: 16),

          // Phone Field
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Téléphone',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),*/
        ],
      ),
    );
  }

  void _saveProfile() {
    storageBox.put('userName', _nameController.text);
    storageBox.put('userEmail', _emailController.text);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil mis à jour'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
