import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

class TransactionApiRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionApiRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    try {
      final models = await remoteDataSource.getTransactions();
      final transactions = models.map((model) => model.toEntity()).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final result = await getTransactions();
    return result.map((transactions) {
      return transactions.where((transaction) {
        return (transaction.date.isAfter(startDate) ||
                transaction.date.isAtSameMomentAs(startDate)) &&
            transaction.date.isBefore(endDate);
      }).toList();
    });
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByType(
    TransactionType type,
  ) async {
    final result = await getTransactions();
    return result.map(
      (transactions) => transactions.where((t) => t.type == type).toList(),
    );
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByCategory(
    String category,
  ) async {
    final result = await getTransactions();
    return result.map(
      (transactions) => transactions
          .where((t) => t.category.toLowerCase() == category.toLowerCase())
          .toList(),
    );
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction(
    Transaction transaction,
  ) async {
    try {
      final model = await remoteDataSource.addTransaction(
        TransactionModel.fromEntity(transaction),
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
    Transaction transaction,
  ) async {
    try {
      final model = await remoteDataSource.updateTransaction(
        TransactionModel.fromEntity(transaction),
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await remoteDataSource.deleteTransaction(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getStatisticsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return Right(await remoteDataSource.getStats());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
