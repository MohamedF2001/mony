import '../../../../core/services/token_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/entities/user.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenService tokenService;
  final UserService userService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenService,
    required this.userService,
  });

  @override
  Future<AuthUser> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);
    final userData = response['data']['user'];
    final token = response['data']['token'];

    final user = AuthUser.fromJson(userData);
    await tokenService.saveToken(token);
    await tokenService.saveUser(user);
    
    // Synchroniser avec le profil local pour le NavigationService
    await userService.saveUser(User(
      id: user.id,
      name: '${user.firstName} ${user.lastName}',
      createdAt: user.createdAt,
    ));
    
    return user;
  }

  @override
  Future<AuthUser> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    String? avatar,
  }) async {
    final response = await remoteDataSource.register(
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      password: password,
      avatar: avatar,
    );
    final userData = response['data']['user'];
    final token = response['data']['token'];

    final user = AuthUser.fromJson(userData);
    await tokenService.saveToken(token);
    await tokenService.saveUser(user);
    
    // Synchroniser avec le profil local pour le NavigationService
    await userService.saveUser(User(
      id: user.id,
      name: '${user.firstName} ${user.lastName}',
      createdAt: user.createdAt,
    ));
    
    return user;
  }

  @override
  Future<void> logout() async {
    await tokenService.removeToken();
    await userService.deleteUser();
  }
}
