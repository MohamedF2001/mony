// lib/features/transaction/domain/usecases/update_transaction.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction {
  final TransactionRepository repository;

  UpdateTransaction(this.repository);

  Future<Either<Failure, Transaction>> call(Transaction transaction) async {
    if (transaction.id == null || transaction.id!.isEmpty) {
      return Left(ValidationFailure('ID de transaction invalide'));
    }

    if (transaction.amount <= 0) {
      return Left(ValidationFailure('Le montant doit être supérieur à 0'));
    }

    return await repository.updateTransaction(transaction);
  }
}
