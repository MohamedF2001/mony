import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/financial_report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, FinancialReport>> generateMonthlyReport(
    int month,
    int year,
  ) async {
    try {
      final response = await remoteDataSource.generateMonthlyReport(month, year);
      final item = response['data']['report'];
      return Right(_mapToEntity(item));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FinancialReport>>> getMyReports() async {
    try {
      final response = await remoteDataSource.getMyReports();
      final List list = response['data'] ?? [];
      return Right(list.map((item) => _mapToEntity(item)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  FinancialReport _mapToEntity(Map<String, dynamic> item) {
    return FinancialReport(
      id: item['_id'],
      period: item['period'] == 'weekly' ? ReportPeriod.weekly : ReportPeriod.monthly,
      startDate: DateTime.parse(item['startDate']),
      endDate: DateTime.parse(item['endDate']),
      content: item['content'],
      score: item['score'] ?? 0,
      createdAt: DateTime.parse(item['createdAt']),
      summary: ReportSummary(
        totalIncome: (item['summary']['totalIncome'] as num).toDouble(),
        totalExpense: (item['summary']['totalExpense'] as num).toDouble(),
        savingsRate: (item['summary']['savingsRate'] as num).toDouble(),
        topCategories: (item['summary']['topCategories'] as List).map((c) => CategorySummary(
          name: c['name'],
          amount: (c['amount'] as num).toDouble(),
        )).toList(),
      ),
      alerts: (item['aiAlerts'] as List? ?? []).map((a) => AIAlert(
        type: a['type'],
        message: a['message'],
        severity: a['severity'],
      )).toList(),
    );
  }
}
