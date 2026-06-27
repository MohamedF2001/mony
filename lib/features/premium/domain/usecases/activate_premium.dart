import 'package:dartz/dartz.dart';
import '../../../../core/entities/user.dart';
import '../../../../core/error/failures.dart';
import '../repositories/premium_repository.dart';

class ActivatePremium {
  final PremiumRepository repository;

  ActivatePremium(this.repository);

  Future<Either<Failure, User>> call(String type) async {
    return await repository.activatePremium(type);
  }
}
