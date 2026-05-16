import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/services/token_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/auth_user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final tokenService = ref.watch(tokenServiceProvider);
  final userService = ref.watch(userServiceProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    tokenService: tokenService,
    userService: userService,
  );
});

class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({AuthUser? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  final SyncService syncService;
  final TokenService tokenService;

  AuthNotifier(this.repository, this.syncService, this.tokenService) : super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final user = await tokenService.getUser();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await repository.login(email, password);
      // Sync local data to API after login
      await syncService.syncLocalDataToApi();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    String? avatar,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await repository.register(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        password: password,
        avatar: avatar,
      );
      // Sync local data to API after registration
      await syncService.syncLocalDataToApi();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await repository.logout();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final syncService = ref.watch(syncServiceProvider);
  final tokenService = ref.watch(tokenServiceProvider);
  return AuthNotifier(repository, syncService, tokenService);
});
