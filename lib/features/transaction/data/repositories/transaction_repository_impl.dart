// lib/features/transaction/data/repositories/transaction_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:mony/features/transaction/data/datasources/transaction_local_datasources.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    try {
      final models = await localDataSource.getTransactions();
      final transactions = models.map((model) => model.toEntity()).toList();
      transactions.sort((a, b) => b.date.compareTo(a.date));
      return Right(transactions);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final models = await localDataSource.getTransactions();
      final filtered = models.where((model) {
        final date = model.date;
        return (date.isAfter(startDate) || date.isAtSameMomentAs(startDate)) &&
            date.isBefore(endDate);
      }).toList();

      final transactions = filtered.map((model) => model.toEntity()).toList();
      transactions.sort((a, b) => b.date.compareTo(a.date));
      return Right(transactions);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByType(
    TransactionType type,
  ) async {
    try {
      final models = await localDataSource.getTransactions();
      final filtered =
          models.where((model) => model.type == type.index).toList();

      final transactions = filtered.map((model) => model.toEntity()).toList();
      transactions.sort((a, b) => b.date.compareTo(a.date));
      return Right(transactions);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByCategory(
    String category,
  ) async {
    try {
      final models = await localDataSource.getTransactions();
      final filtered = models
          .where(
              (model) => model.category.toLowerCase() == category.toLowerCase())
          .toList();

      final transactions = filtered.map((model) => model.toEntity()).toList();
      transactions.sort((a, b) => b.date.compareTo(a.date));
      return Right(transactions);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction(
    Transaction transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final addedModel = await localDataSource.addTransaction(model);
      return Right(addedModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
    Transaction transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final updatedModel = await localDataSource.updateTransaction(model);
      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await localDataSource.deleteTransaction(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getStatisticsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await getTransactionsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );

      return result.fold(
        (failure) => Left(failure),
        (transactions) {
          double totalIncome = 0;
          double totalExpense = 0;

          for (final transaction in transactions) {
            if (transaction.isIncome) {
              totalIncome += transaction.amount;
            } else {
              totalExpense += transaction.amount;
            }
          }

          return Right({
            'income': totalIncome,
            'expense': totalExpense,
            'balance': totalIncome - totalExpense,
          });
        },
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
