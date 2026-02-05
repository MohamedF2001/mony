// lib/features/transaction/domain/repositories/transaction_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions();

  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, List<Transaction>>> getTransactionsByType(
    TransactionType type,
  );

  Future<Either<Failure, List<Transaction>>> getTransactionsByCategory(
    String category,
  );

  Future<Either<Failure, Transaction>> addTransaction(Transaction transaction);

  Future<Either<Failure, Transaction>> updateTransaction(
    Transaction transaction,
  );

  Future<Either<Failure, void>> deleteTransaction(String id);

  Future<Either<Failure, Map<String, double>>> getStatisticsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  });
}
