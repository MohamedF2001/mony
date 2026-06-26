import 'package:mony/features/coaching/domain/entities/financial_report.dart';

abstract class ReportRepository {
  Future<FinancialReport> generateMonthlyReport(int month, int year);
  Future<List<FinancialReport>> getMyReports();
}
