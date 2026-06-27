import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/financial_report.dart';
import '../repositories/report_repository.dart';

class GetMyReports {
  final ReportRepository repository;

  GetMyReports(this.repository);

  Future<Either<Failure, List<FinancialReport>>> call() async {
    return await repository.getMyReports();
  }
}
