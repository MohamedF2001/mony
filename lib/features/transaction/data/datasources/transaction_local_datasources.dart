// lib/features/transaction/data/datasources/transaction_local_datasource.dart

import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<TransactionModel> addTransaction(TransactionModel transaction);
  Future<TransactionModel> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<void> clearAll();
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final Box<TransactionModel> box;

  TransactionLocalDataSourceImpl(this.box);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      return box.values.toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des transactions: $e');
    }
  }

  @override
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    try {
      await box.put(transaction.id, transaction);
      return transaction;
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la transaction: $e');
    }
  }

  @override
  Future<TransactionModel> updateTransaction(
    TransactionModel transaction,
  ) async {
    try {
      await box.put(transaction.id, transaction);
      return transaction;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await box.delete(id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la transaction: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await box.clear();
    } catch (e) {
      throw Exception(
          'Erreur lors de la suppression de toutes les transactions: $e');
    }
  }
}
