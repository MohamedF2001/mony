// lib/features/export/domain/usecases/export_to_excel.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;
import '../../../../core/error/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../transaction/domain/entities/transaction.dart';

class ExportToExcel {
  Future<Either<Failure, String>> call({
    required List<Transaction> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Transactions'];

      // Set column widths
      sheet.setColumnWidth(0, 15);
      sheet.setColumnWidth(1, 20);
      sheet.setColumnWidth(2, 15);
      sheet.setColumnWidth(3, 15);
      sheet.setColumnWidth(4, 30);

      // Header style
      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#2D6CFF'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      // Add headers
      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Date');
      sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Catégorie');
      sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Type');
      sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Montant');
      sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Description');

      // Apply header style
      for (var col in ['A1', 'B1', 'C1', 'D1', 'E1']) {
        sheet.cell(CellIndex.indexByString(col)).cellStyle = headerStyle;
      }

      // Add data
      int row = 2;
      double totalIncome = 0;
      double totalExpense = 0;

      for (var transaction in transactions) {
        sheet.cell(CellIndex.indexByString('A$row')).value =
            TextCellValue(transaction.date.toFormattedDate());
        sheet.cell(CellIndex.indexByString('B$row')).value =
            TextCellValue(transaction.category);
        sheet.cell(CellIndex.indexByString('C$row')).value =
            TextCellValue(transaction.isIncome ? 'Revenu' : 'Dépense');
        sheet.cell(CellIndex.indexByString('D$row')).value =
            DoubleCellValue(transaction.amount);
        sheet.cell(CellIndex.indexByString('E$row')).value =
            TextCellValue(transaction.description ?? '');

        // Apply amount color
        final amountCell = sheet.cell(CellIndex.indexByString('D$row'));
        amountCell.cellStyle = CellStyle(
          fontColorHex: ExcelColor.fromHexString(transaction.isIncome ? '#00D09C' : '#FF6B6B'),
        );

        if (transaction.isIncome) {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount;
        }

        row++;
      }

      // Add summary
      row += 2;
      final summaryStyle = CellStyle(bold: true);

      sheet.cell(CellIndex.indexByString('C$row')).value =
          TextCellValue('Total Revenus:');
      sheet.cell(CellIndex.indexByString('C$row')).cellStyle = summaryStyle;
      sheet.cell(CellIndex.indexByString('D$row')).value =
          DoubleCellValue(totalIncome);
      sheet.cell(CellIndex.indexByString('D$row')).cellStyle = CellStyle(
        fontColorHex: ExcelColor.fromHexString('#00D09C'),
        bold: true,
      );

      row++;
      sheet.cell(CellIndex.indexByString('C$row')).value =
          TextCellValue('Total Dépenses:');
      sheet.cell(CellIndex.indexByString('C$row')).cellStyle = summaryStyle;
      sheet.cell(CellIndex.indexByString('D$row')).value =
          DoubleCellValue(totalExpense);
      sheet.cell(CellIndex.indexByString('D$row')).cellStyle = CellStyle(
        fontColorHex: ExcelColor.fromHexString('#FF6B6B'),
        bold: true,
      );

      row++;
      sheet.cell(CellIndex.indexByString('C$row')).value =
          TextCellValue('Solde:');
      sheet.cell(CellIndex.indexByString('C$row')).cellStyle = summaryStyle;
      final balance = totalIncome - totalExpense;
      sheet.cell(CellIndex.indexByString('D$row')).value =
          DoubleCellValue(balance);
      sheet.cell(CellIndex.indexByString('D$row')).cellStyle = CellStyle(
        fontColorHex: balance >= 0 ? ExcelColor.fromHexString('#4CAF50') : ExcelColor.fromHexString('#EF5350'),
        bold: true,
      );

      final excelBytes = excel.encode();
      if (excelBytes == null) {
        throw Exception('Impossible de générer le fichier Excel');
      }

      // WEB: Download directly
      if (kIsWeb) {
        final bytes = Uint8List.fromList(excelBytes);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'mony_export_${DateTime.now().millisecondsSinceEpoch}.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);
        return const Right('Excel téléchargé');
      }
      // MOBILE: Save and share with share_plus
      else {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/mony_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(excelBytes);

        // Share the file
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Export Mony - ${startDate.toFormattedDate()} à ${endDate.toFormattedDate()}',
        );

        return const Right('Excel partagé');
      }
    } catch (e) {
      return Left(UnexpectedFailure('Erreur lors de la création du fichier Excel: $e'));
    }
  }
}