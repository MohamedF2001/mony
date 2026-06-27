import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../academy/domain/entities/premium_content.dart';
import '../../../premium/domain/repositories/premium_repository.dart';

class GetPdfs {
  final PremiumRepository repository;

  GetPdfs(this.repository);

  Future<Either<Failure, List<PremiumContent>>> call() async {
    return await repository.getPdfs();
  }
}
