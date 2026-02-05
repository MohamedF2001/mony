// lib/features/transaction/domain/usecases/get_transactions.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactions {
  final TransactionRepository repository;

  GetTransactions(this.repository);

  Future<Either<Failure, List<Transaction>>> call() async {
    return await repository.getTransactions();
  }
}

class GetTransactionsByDateRange {
  final TransactionRepository repository;

  GetTransactionsByDateRange(this.repository);

  Future<Either<Failure, List<Transaction>>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (startDate.isAfter(endDate)) {
      return Left(ValidationFailure(
        'La date de début doit être antérieure à la date de fin',
      ));
    }

    return await repository.getTransactionsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
