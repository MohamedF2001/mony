/*
// lib/features/profile/presentation/screens/user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/entities/user.dart';
import '../../../financial_profile/domain/entities/financial_trait.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nom ne peut pas être vide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref.read(userProvider.notifier).updateName(_nameController.text.trim());

    if (!mounted) return;

    setState(() => _isEditingName = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nom mis à jour avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
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
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(userProvider.notifier).loadUser(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Aucun utilisateur trouvé'),
            );
          }

          // Initialiser le controller avec le nom actuel
          if (_nameController.text.isEmpty && !_isEditingName) {
            _nameController.text = user.name;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header avec avatar
                _buildHeader(user),

                const SizedBox(height: 24),

                // Section Informations personnelles
                _buildPersonalInfoSection(user),

                const SizedBox(height: 16),

                // Section Profil financier
                if (user.hasFinancialProfile)
                  _buildFinancialProfileSection(user),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Nom
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Date d'inscription
          Text(
            'Membre depuis ${_formatDate(user.createdAt)}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(User user) {
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
              const Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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

          // Champ nom
          if (_isEditingName)
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nom',
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
              title: const Text('Nom'),
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

  Widget _buildFinancialProfileSection(User user) {
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
          const Text(
            'Profil Financier',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Type de profil
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              //color: profile.type.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                //color: profile.type.color,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  //profile.type.icon,
                  //color: profile.type.color,
                  Icons.account_balance_wallet,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          //color: profile.type.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Confiance: ${profile.confidenceScore.toInt()}%',
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

          // Scores des traits
          const Text(
            'Analyse détaillée',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          ...profile.traitScores.entries.map((entry) {
            //final label = FinancialTrait.getLabelFor(entry.key);
            final label = entry.key.label;
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
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

          const SizedBox(height: 16),

          // Bouton refaire le questionnaire
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Naviguer vers le questionnaire
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité à venir'),
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refaire le questionnaire'),
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

  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _getColorForScore(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.blue;
    if (score >= 25) return Colors.orange;
    return Colors.red;
  }
}*/

// lib/features/profile/presentation/screens/user_profile_screen.dart

/*import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/entities/user.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../category/presentation/providers/category_providers.dart';
import '../../../financial_profile/domain/entities/financial_trait.dart';
import '../../../financial_profile/presentation/screens/questionnaire_screen.dart';
import '../../../settings/presentation/providers/app_reset_service_provider.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nom ne peut pas être vide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref.read(userProvider.notifier).updateName(_nameController.text.trim());

    if (!mounted) return;

    setState(() => _isEditingName = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nom mis à jour avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        */ /*leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),*/ /*
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
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
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(userProvider.notifier).loadUser(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Aucun utilisateur trouvé'),
            );
          }

          // Initialiser le controller avec le nom actuel
          if (_nameController.text.isEmpty && !_isEditingName) {
            _nameController.text = user.name;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header avec avatar
                _buildHeader(user),

                const SizedBox(height: 24),

                // Section Informations personnelles
                _buildPersonalInfoSection(user),

                const SizedBox(height: 16),

                // Section Profil financier
                if (user.hasFinancialProfile)
                  _buildFinancialProfileSection(user),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Nom
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Date d'inscription
          Text(
            'Membre depuis ${_formatDate(user.createdAt)}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(User user) {
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
              const Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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

          // Champ nom
          if (_isEditingName)
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nom',
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
              title: const Text('Nom'),
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

  Widget _buildFinancialProfileSection(User user) {
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
          const Text(
            'Profil Financier',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Type de profil
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              //color: profile.type.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                //color: profile.type.color,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  //profile.type.icon,
                  Icons.eleven_mp,
                  //color: profile.type.color,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          //color: profile.type.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Confiance: ${profile.confidenceScore.toInt()}%',
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

          // Scores des traits
          const Text(
            'Analyse détaillée',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          ...profile.traitScores.entries.map((entry) {
            final traitType = entry.key;
            final label = _getLabelForTrait(traitType);
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
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

          const SizedBox(height: 16),

          // Bouton refaire le questionnaire
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Naviguer vers le questionnaire
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité à venir'),
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refaire le questionnaire'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          _buildSection(
            title: 'Application',
            children: [
              */ /*_buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),*/ /*
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

  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _getColorForScore(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.blue;
    if (score >= 25) return Colors.orange;
    return Colors.red;
  }

  String _getLabelForTrait(FinancialTraitType type) {
    switch (type) {
      case FinancialTraitType.impulsivity:
        return 'Impulsivité';
      case FinancialTraitType.discipline:
        return 'Discipline';
      case FinancialTraitType.savingCapacity:
        return 'Capacité d\'épargne';
      case FinancialTraitType.emotionalControl:
        return 'Contrôle émotionnel';
      case FinancialTraitType.organizationLevel:
        return 'Organisation';
      case FinancialTraitType.riskTolerance:
        return 'Tolérance au risque';
    }
  }
}*/

// lib/features/profile/presentation/screens/user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/entities/user.dart';
import '../../../budget/presentation/providers/budget_providers.dart';
import '../../../category/presentation/providers/category_providers.dart';
import '../../../financial_profile/domain/entities/financial_profile.dart';
import '../../../financial_profile/domain/entities/financial_trait.dart';
import '../../../financial_profile/presentation/screens/questionnaire_screen.dart';
import '../../../settings/presentation/providers/app_reset_service_provider.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nom ne peut pas être vide'),
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
      const SnackBar(
        content: Text('Nom mis à jour avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        /*leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),*/
        title: const Text(
          'Mon Profil',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
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
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(userProvider.notifier).loadUser(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Aucun utilisateur trouvé'));
          }

          // Initialiser le controller avec le nom actuel
          if (_nameController.text.isEmpty && !_isEditingName) {
            _nameController.text = user.name;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header avec avatar
                _buildHeader(user),

                const SizedBox(height: 24),

                // Section Informations personnelles
                _buildPersonalInfoSection(user),

                const SizedBox(height: 16),

                // Section Profil financier
                if (user.hasFinancialProfile)
                  _buildFinancialProfileSection(user),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Nom
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Date d'inscription
          Text(
            'Membre depuis ${_formatDate(user.createdAt)}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(User user) {
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
              const Text(
                'Informations personnelles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

          // Champ nom
          if (_isEditingName)
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nom',
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
              title: const Text('Nom'),
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

  Widget _buildFinancialProfileSection(User user) {
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
          const Text(
            'Profil Financier',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // Type de profil
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              //color: profile.type.color.withOpacity(0.1),
              color: _getColorForProfileType(profile.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getColorForProfileType(profile.type),
                //color: profile.type.color,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  //profile.type.icon,
                  _getIconForProfileType(profile.type),
                  //color: profile.type.color,
                  color: _getColorForProfileType(profile.type),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          //color: profile.type.color,
                          color: _getColorForProfileType(profile.type),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Confiance: ${profile.confidenceScore.toInt()}%',
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

          // Scores des traits
          const Text(
            'Analyse détaillée',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 16),

          ...profile.traitScores.entries.map((entry) {
            final traitType = entry.key;
            final label = _getLabelForTrait(traitType);
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
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

          const SizedBox(height: 16),

          // Bouton refaire le questionnaire
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Naviguer vers le questionnaire
                Navigator.of(context).pushNamed('/questionnaire');
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refaire le questionnaire'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          _buildSection(
            title: 'Application',
            children: [
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

  String _formatDate(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _getColorForScore(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.blue;
    if (score >= 25) return Colors.orange;
    return Colors.red;
  }

  String _getLabelForTrait(FinancialTraitType type) {
    switch (type) {
      case FinancialTraitType.impulsivity:
        return 'Impulsivité';
      case FinancialTraitType.discipline:
        return 'Discipline';
      case FinancialTraitType.savingCapacity:
        return 'Capacité d\'épargne';
      case FinancialTraitType.emotionalControl:
        return 'Contrôle émotionnel';
      case FinancialTraitType.organizationLevel:
        return 'Organisation';
      case FinancialTraitType.riskTolerance:
        return 'Tolérance au risque';
    }
  }

  Color _getColorForProfileType(ProfileType type) {
    switch (type) {
      case ProfileType.impulsiveSpender:
        return const Color(0xFFFF6B6B);
      case ProfileType.balancedAware:
        return const Color(0xFF4CAF50);
      case ProfileType.strategicSaver:
        return const Color(0xFF2196F3);
      case ProfileType.overController:
        return const Color(0xFF9C27B0);
      case ProfileType.financiallyDisorganized:
        return const Color(0xFFFF9800);
      case ProfileType.cautiousOptimizer:
        return const Color(0xFF00BCD4);
    }
  }

  IconData _getIconForProfileType(ProfileType type) {
    switch (type) {
      case ProfileType.impulsiveSpender:
        return Icons.shopping_bag;
      case ProfileType.balancedAware:
        return Icons.balance;
      case ProfileType.strategicSaver:
        return Icons.savings;
      case ProfileType.overController:
        return Icons.lock;
      case ProfileType.financiallyDisorganized:
        return Icons.shuffle;
      case ProfileType.cautiousOptimizer:
        return Icons.psychology;
    }
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
            child: Text(title, style: AppTypography.textTheme.titleSmall),
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
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Future<void> _resetAllData() async {
    try {
      await ref.read(appResetServiceProvider).resetAll();

      ref.invalidate(transactionProvider);
      ref.invalidate(categoryProvider);
      ref.invalidate(budgetProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Données réinitialisées')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const QuestionnaireScreen();
            //return const OnboardingScreen();
          },
        ),
      );
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
