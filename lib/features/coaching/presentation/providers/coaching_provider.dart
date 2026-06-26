import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_providers.dart';
import '../../data/datasources/report_remote_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/financial_report.dart';
import '../../domain/repositories/report_repository.dart';

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReportRemoteDataSourceImpl(apiClient);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final remoteDataSource = ref.watch(reportRemoteDataSourceProvider);
  return ReportRepositoryImpl(remoteDataSource);
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
  final ReportRepository repository;

  CoachingNotifier(this.repository) : super(CoachingState());

  Future<void> fetchReports() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reports = await repository.getMyReports();
      state = state.copyWith(reports: reports, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> generateReport(int month, int year) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final report = await repository.generateMonthlyReport(month, year);
      state = state.copyWith(
        reports: [report, ...state.reports],
        currentReport: report,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final coachingProvider = StateNotifierProvider<CoachingNotifier, CoachingState>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return CoachingNotifier(repository);
});
