import 'package:uuid/uuid.dart';

class Transaction {
  final String id;
  final String type; // 'expense' or 'income'
  final double amount;
  final String category;
  final String? note;
  final DateTime date;

  Transaction({
    String? id,
    required this.type,
    required this.amount,
    required this.category,
    this.note,
    DateTime? date,
  }) : id = id ?? const Uuid().v4(),
       date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'amount': amount,
    'category': category,
    'note': note,
    'date': date.toIso8601String(),
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'] as String,
    type: json['type'] as String,
    amount: (json['amount'] as num).toDouble(),
    category: json['category'] as String,
    note: json['note'] as String?,
    date: DateTime.parse(json['date'] as String),
  );
}
