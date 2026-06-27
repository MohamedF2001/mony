import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../premium/presentation/providers/premium_provider.dart';
import '../../domain/entities/premium_content.dart';
import '../../domain/usecases/get_content_by_id.dart';
import '../../domain/usecases/get_pdf_by_id.dart';
import '../../domain/usecases/get_pdfs.dart';
import '../../domain/usecases/get_premium_contents.dart';

final getPremiumContentsUseCaseProvider = Provider<GetPremiumContents>((ref) {
  final repository = ref.watch(premiumRepositoryProvider);
  return GetPremiumContents(repository);
});

final getPdfsUseCaseProvider = Provider<GetPdfs>((ref) {
  final repository = ref.watch(premiumRepositoryProvider);
  return GetPdfs(repository);
});

final getPdfByIdUseCaseProvider = Provider<GetPdfById>((ref) {
  final repository = ref.watch(premiumRepositoryProvider);
  return GetPdfById(repository);
});

final getContentByIdUseCaseProvider = Provider<GetContentById>((ref) {
  final repository = ref.watch(premiumRepositoryProvider);
  return GetContentById(repository);
});

class AcademyState {
  final List<PremiumContent> contents;
  final bool isLoading;
  final String? error;

  AcademyState({
    this.contents = const [],
    this.isLoading = false,
    this.error,
  });

  AcademyState copyWith({
    List<PremiumContent>? contents,
    bool? isLoading,
    String? error,
  }) {
    return AcademyState(
      contents: contents ?? this.contents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AcademyNotifier extends StateNotifier<AcademyState> {
  final GetPremiumContents getPremiumContentsUseCase;
  final GetPdfs getPdfsUseCase;

  AcademyNotifier({
    required this.getPremiumContentsUseCase,
    required this.getPdfsUseCase,
  }) : super(AcademyState());

  Future<void> fetchContents({String? type, String? category}) async {
    state = state.copyWith(isLoading: true, error: null);
    final List<PremiumContent> allContents = [];

    // Fetch PDFs from the new API
    if (type == null || type == 'ebook') {
      final pdfsResult = await getPdfsUseCase();
      pdfsResult.fold(
        (failure) => null, // Handle failure if needed
        (pdfs) => allContents.addAll(pdfs),
      );
    }

    // Fetch other contents from the existing API
    final contentsResult =
        await getPremiumContentsUseCase(type: type, category: category);
    contentsResult.fold(
      (failure) => null, // Handle failure if needed
      (contents) => allContents.addAll(contents),
    );

    state = state.copyWith(contents: allContents, isLoading: false);
  }
}

final academyProvider =
    StateNotifierProvider<AcademyNotifier, AcademyState>((ref) {
  final getPremiumContentsUseCase = ref.watch(getPremiumContentsUseCaseProvider);
  final getPdfsUseCase = ref.watch(getPdfsUseCaseProvider);
  return AcademyNotifier(
    getPremiumContentsUseCase: getPremiumContentsUseCase,
    getPdfsUseCase: getPdfsUseCase,
  );
});
