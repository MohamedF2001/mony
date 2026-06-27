import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../academy/domain/entities/premium_content.dart';
import '../../../premium/domain/repositories/premium_repository.dart';

class GetPremiumContents {
  final PremiumRepository repository;

  GetPremiumContents(this.repository);

  Future<Either<Failure, List<PremiumContent>>> call({
    String? type,
    String? category,
  }) async {
    return await repository.getPremiumContents(type: type, category: category);
  }
}
