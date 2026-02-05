// lib/features/export/presentation/providers/export_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/export_to_excel.dart';
import '../../domain/usecases/export_to_pdf.dart';

final exportToPdfUseCaseProvider = Provider<ExportToPdf>((ref) {
  return ExportToPdf();
});

final exportToExcelUseCaseProvider = Provider<ExportToExcel>((ref) {
  return ExportToExcel();
});