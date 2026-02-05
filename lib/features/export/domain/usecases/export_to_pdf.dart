// lib/features/export/domain/usecases/export_to_pdf.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../transaction/domain/entities/transaction.dart';

class ExportToPdf {
  Future<Either<Failure, dynamic>> call({
    required List<Transaction> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final pdf = pw.Document();

      // Calculate totals
      double totalIncome = 0;
      double totalExpense = 0;

      for (var transaction in transactions) {
        if (transaction.isIncome) {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount;
        }
      }

      final balance = totalIncome - totalExpense;

      // Add page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#2D6CFF'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'RAPPORT FINANCIER',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Période: ${startDate.toFormattedDate()} - ${endDate.toFormattedDate()}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Summary Cards
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCard(
                  'Revenus',
                  totalIncome.toFormattedMoney(),
                  PdfColor.fromHex('#00D09C'),
                ),
                _buildSummaryCard(
                  'Dépenses',
                  totalExpense.toFormattedMoney(),
                  PdfColor.fromHex('#FF6B6B'),
                ),
                _buildSummaryCard(
                  'Solde',
                  balance.toFormattedMoney(),
                  balance >= 0
                      ? PdfColor.fromHex('#4CAF50')
                      : PdfColor.fromHex('#EF5350'),
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // Transactions Table
            pw.Text(
              'Détail des transactions',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFEFEFEF),
                  ),
                  children: [
                    _buildTableCell('Date', isHeader: true),
                    _buildTableCell('Catégorie', isHeader: true),
                    _buildTableCell('Description', isHeader: true),
                    _buildTableCell('Montant', isHeader: true),
                  ],
                ),

                // Data rows
                ...transactions.map((transaction) {
                  return pw.TableRow(
                    children: [
                      _buildTableCell(transaction.date.toFormattedDate()),
                      _buildTableCell(transaction.category),
                      _buildTableCell(transaction.description ?? '-'),
                      _buildTableCell(
                        '${transaction.isIncome ? '+' : '-'} ${transaction.amount.toFormattedMoney()}',
                        color: transaction.isIncome
                            ? PdfColor.fromHex('#00D09C')
                            : PdfColor.fromHex('#FF6B6B'),
                      ),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 20),

            // Footer
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              'Généré par Mony App - ${DateTime.now().toFormattedDateLong()}',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey,
              ),
            ),
          ],
        ),
      );

      final pdfBytes = await pdf.save();

      // WEB: Download directly using printing package
      if (kIsWeb) {
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: 'mony_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        return const Right('PDF téléchargé');
      }
      // MOBILE: Share PDF
      else {
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: 'mony_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        return const Right('PDF partagé');
      }
    } catch (e) {
      return Left(UnexpectedFailure('Erreur lors de la création du PDF: $e'));
    }
  }

  pw.Widget _buildSummaryCard(String title, String amount, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            amount,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
      ),
    );
  }
}