// lib/features/transaction/domain/usecases/add_transaction.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransaction {
  final TransactionRepository repository;

  AddTransaction(this.repository);

  Future<Either<Failure, Transaction>> call(Transaction transaction) async {
    // Validation métier
    if (transaction.amount <= 0) {
      return Left(ValidationFailure('Le montant doit être supérieur à 0'));
    }

    if (transaction.category.isEmpty) {
      return Left(ValidationFailure('La catégorie est requise'));
    }

    return await repository.addTransaction(transaction);
  }
}
