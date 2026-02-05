// lib/features/export/presentation/widgets/export_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../providers/export_providers.dart';

class ExportService {
  static Future<void> exportToPdf(
      BuildContext context,
      WidgetRef ref,
      ) async {
    // Show loading
    /*showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );*/

    try {
      final transactions = ref.read(filteredTransactionsProvider);
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));

      final exportUseCase = ref.read(exportToPdfUseCaseProvider);
      final result = await exportUseCase(
        transactions: transactions,
        startDate: startDate,
        endDate: now,
      );

      if (!context.mounted) return;

      // TOUJOURS fermer le loading en premier
      Navigator.pop(context);

      result.fold(
            (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.error,
            ),
          );
        },
            (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ PDF exporté avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;

      // Fermer le loading même en cas d'erreur
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  static Future<void> exportToExcel(
      BuildContext context,
      WidgetRef ref,
      ) async {
    // Show loading
    /*showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );*/

    try {
      final transactions = ref.read(filteredTransactionsProvider);
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));

      final exportUseCase = ref.read(exportToExcelUseCaseProvider);
      final result = await exportUseCase(
        transactions: transactions,
        startDate: startDate,
        endDate: now,
      );

      if (!context.mounted) return;

      // TOUJOURS fermer le loading en premier
      Navigator.pop(context);

      result.fold(
            (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: AppColors.error,
            ),
          );
        },
            (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Excel exporté avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;

      // Fermer le loading même en cas d'erreur
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}