import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../../transaction/presentation/screens/add_transaction_screen.dart';
import '../../../statistics/presentation/screens/statistics_screen.dart';
import '../../../category/presentation/screens/category_screen.dart';
import '../../../export/presentation/widgets/export_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
           /* Expanded(
              child: _QuickActionButton(
                icon: Icons.add,
                label: 'Ajouter',
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTransactionScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),*/
            Expanded(
              child: _QuickActionButton(
                icon: Icons.bar_chart,
                label: 'Statistiques',
                color: AppColors.accent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatisticsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.category,
                label: 'Catégories',
                color: AppColors.success,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoryScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            /*Expanded(
              child: _QuickActionButton(
                icon: Icons.smart_toy,
                label: 'Assistant IA',
                color: AppColors.accent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiAssistantScreen(),
                    ),
                  );
                },
              ),
            ),*/
            Expanded(
              child: _QuickActionButton(
                icon: Icons.smart_toy,
                label: 'Assistant IA',
                color: AppColors.accent,
                onTap: () async {
                  // Vérifier la connexion internet
                  final connectivityResult = await Connectivity().checkConnectivity();

                  if (connectivityResult == ConnectivityResult.none) {
                    // Pas de connexion internet
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Aucune connexion internet disponible'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  } else {
                    // Connexion disponible, naviguer vers la page
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AiAssistantScreen(),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.download,
                label: 'Exporter',
                color: AppColors.primary,
                onTap: () {
                  _showExportOptions(context, ref);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /*void _showExportOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exporter les données',
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _ExportOption(
                      icon: Icons.picture_as_pdf,
                      title: 'Exporter en PDF',
                      subtitle: 'Rapport complet avec graphiques',
                      onTap: () {
                        Navigator.pop(context);
                        ExportService.exportToPdf(context, ref);
                      },
                    ),
                    const SizedBox(height: 12),
                    _ExportOption(
                      icon: Icons.table_chart,
                      title: 'Exporter en Excel',
                      subtitle: 'Données brutes en CSV/XLSX',
                      onTap: () {
                        Navigator.pop(context);
                        ExportService.exportToExcel(context, ref);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }*/

  void _showExportOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exporter les données',
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _ExportOption(
                      icon: Icons.picture_as_pdf,
                      title: 'Exporter en PDF',
                      subtitle: 'Rapport complet avec graphiques',
                      onTap: () async {
                        Navigator.pop(context); // Fermer le bottom sheet

                        // Afficher un loading
                        // showDialog(
                        //   context: context,
                        //   barrierDismissible: false,
                        //   builder: (context) => const Center(
                        //     child: CircularProgressIndicator(),
                        //   ),
                        // );

                        // Exporter
                        await ExportService.exportToPdf(context, ref);

                        // Fermer le loading
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _ExportOption(
                      icon: Icons.table_chart,
                      title: 'Exporter en Excel',
                      subtitle: 'Données brutes en CSV/XLSX',
                      onTap: () async {
                        Navigator.pop(context); // Fermer le bottom sheet

                        // Afficher un loading
                        // showDialog(
                        //   context: context,
                        //   barrierDismissible: false,
                        //   builder: (context) => const Center(
                        //     child: CircularProgressIndicator(),
                        //   ),
                        // );

                        // Exporter
                        await ExportService.exportToExcel(context, ref);

                        // Fermer le loading
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
