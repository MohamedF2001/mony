import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import 'package:mony/features/coaching/domain/entities/financial_report.dart';

abstract class ReportRepository {
  Future<Either<Failure, FinancialReport>> generateMonthlyReport(
    int month,
    int year,
  );
  Future<Either<Failure, List<FinancialReport>>> getMyReports();
}
