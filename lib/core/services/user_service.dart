import '../entities/user.dart';
import '../../features/financial_profile/domain/entities/financial_profile.dart';

/// Service pour gérer l'utilisateur (Gestion via API recommandée)
class UserService {
  // Cette classe doit désormais communiquer avec l'API pour récupérer les infos utilisateur
  // Pour l'instant, on garde une structure qui permet d'éviter les erreurs de compilation

  Future<User?> getCurrentUser() async {
    // Devrait appeler l'API
    return null;
  }

  Future<void> saveUser(User user) async {
    // Devrait appeler l'API
  }

  Future<void> updateName(String name) async {
    // Devrait appeler l'API
  }

  Future<void> updateFinancialProfile(FinancialProfile profile) async {
    // Devrait appeler l'API
  }

  Future<bool> isOnboardingComplete() async {
    return false;
  }

  bool hasFinancialProfile() {
    return false;
  }

  bool hasName() {
    return false;
  }

  Future<void> deleteUser() async {
    // Devrait appeler l'API
  }
}
