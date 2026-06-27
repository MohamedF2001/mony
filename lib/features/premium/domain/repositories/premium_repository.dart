import 'package:dartz/dartz.dart';
import '../../../../core/entities/user.dart';
import '../../../../core/error/failures.dart';
import '../../../academy/domain/entities/premium_content.dart';

abstract class PremiumRepository {
  Future<Either<Failure, User>> activatePremium(String type);
  Future<Either<Failure, List<PremiumContent>>> getPremiumContents({
    String? type,
    String? category,
  });
  Future<Either<Failure, List<PremiumContent>>> getPdfs();
  Future<Either<Failure, PremiumContent>> getPdfById(String id);
  Future<Either<Failure, PremiumContent>> getContentById(String id);
}
