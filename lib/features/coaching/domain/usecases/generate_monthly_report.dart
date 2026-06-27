import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/financial_report.dart';
import '../repositories/report_repository.dart';

class GenerateMonthlyReport {
  final ReportRepository repository;

  GenerateMonthlyReport(this.repository);

  Future<Either<Failure, FinancialReport>> call(int month, int year) async {
    return await repository.generateMonthlyReport(month, year);
  }
}
