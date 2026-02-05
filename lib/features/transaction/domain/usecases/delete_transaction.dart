// lib/features/transaction/domain/usecases/delete_transaction.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository repository;

  DeleteTransaction(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    if (id.isEmpty) {
      return Left(ValidationFailure('ID de transaction invalide'));
    }

    return await repository.deleteTransaction(id);
  }
}
