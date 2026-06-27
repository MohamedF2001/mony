//part 'transaction.g.dart';

enum TransactionType {
  income,
  expense,
}

class Transaction {
  int id = 0;
  DateTime date;
  String category;
  double amount;
  TransactionType type;
  String? description;
  Transaction(
      {required this.date,
      required this.category,
      required this.amount,
      required this.type,
      this.description});
  @override
  String toString() {
    return 'date: $date,category: $category,amount: $amount,type: $type, description: $description';
  }
}