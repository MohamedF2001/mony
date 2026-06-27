import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_providers.dart';
import '../../data/datasources/report_remote_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/financial_report.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/generate_monthly_report.dart';
import '../../domain/usecases/get_my_reports.dart';

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReportRemoteDataSourceImpl(apiClient);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final remoteDataSource = ref.watch(reportRemoteDataSourceProvider);
  return ReportRepositoryImpl(remoteDataSource);
});

final generateMonthlyReportUseCaseProvider =
    Provider<GenerateMonthlyReport>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return GenerateMonthlyReport(repository);
});

final getMyReportsUseCaseProvider = Provider<GetMyReports>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return GetMyReports(repository);
});

class CoachingState {
  final List<FinancialReport> reports;
  final bool isLoading;
  final String? error;
  final FinancialReport? currentReport;

  CoachingState({
    this.reports = const [],
    this.isLoading = false,
    this.error,
    this.currentReport,
  });

  CoachingState copyWith({
    List<FinancialReport>? reports,
    bool? isLoading,
    String? error,
    FinancialReport? currentReport,
  }) {
    return CoachingState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentReport: currentReport ?? this.currentReport,
    );
  }
}

class CoachingNotifier extends StateNotifier<CoachingState> {
  final GetMyReports getMyReportsUseCase;
  final GenerateMonthlyReport generateMonthlyReportUseCase;

  CoachingNotifier({
    required this.getMyReportsUseCase,
    required this.generateMonthlyReportUseCase,
  }) : super(CoachingState());

  Future<void> fetchReports() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getMyReportsUseCase();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (reports) => state = state.copyWith(reports: reports, isLoading: false),
    );
  }

  Future<void> generateReport(int month, int year) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await generateMonthlyReportUseCase(month, year);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (report) => state = state.copyWith(
        reports: [report, ...state.reports],
        currentReport: report,
        isLoading: false,
      ),
    );
  }
}

final coachingProvider =
    StateNotifierProvider<CoachingNotifier, CoachingState>((ref) {
  final getMyReportsUseCase = ref.watch(getMyReportsUseCaseProvider);
  final generateMonthlyReportUseCase =
      ref.watch(generateMonthlyReportUseCaseProvider);
  return CoachingNotifier(
    getMyReportsUseCase: getMyReportsUseCase,
    generateMonthlyReportUseCase: generateMonthlyReportUseCase,
  );
});
