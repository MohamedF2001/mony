import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../academy/domain/entities/premium_content.dart';
import '../../../premium/domain/repositories/premium_repository.dart';

class GetContentById {
  final PremiumRepository repository;

  GetContentById(this.repository);

  Future<Either<Failure, PremiumContent>> call(String id) async {
    return await repository.getContentById(id);
  }
}
