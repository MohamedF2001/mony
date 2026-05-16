import '../models/auth_user_model.dart';

abstract class AuthRepository {
  Future<AuthUser> login(String email, String password);
  Future<AuthUser> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    String? avatar,
  });
  Future<void> logout();
}
