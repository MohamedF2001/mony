import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../premium/domain/repositories/premium_repository.dart';
import '../../../premium/presentation/providers/premium_provider.dart';
import '../../domain/entities/premium_content.dart';

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
  final PremiumRepository repository;

  AcademyNotifier(this.repository) : super(AcademyState());

  Future<void> fetchContents({String? type, String? category}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final List<PremiumContent> allContents = [];

      // Fetch PDFs from the new API
      if (type == null || type == 'ebook') {
        try {
          final pdfs = await repository.getPdfs();
          allContents.addAll(pdfs);
        } catch (e) {
          // Log or handle error for PDFs specifically
        }
      }

      // Fetch other contents from the existing API
      try {
        final contents = await repository.getPremiumContents(type: type, category: category);
        allContents.addAll(contents);
      } catch (e) {
        // Log or handle error for premium contents specifically
      }

      state = state.copyWith(contents: allContents, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final academyProvider = StateNotifierProvider<AcademyNotifier, AcademyState>((ref) {
  final repository = ref.watch(premiumRepositoryProvider);
  return AcademyNotifier(repository);
});
