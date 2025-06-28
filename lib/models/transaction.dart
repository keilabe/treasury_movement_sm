enum TransactionStatus { completed, scheduled }

class Transaction {
  final String id;
  final String fromAccountId;
  final String toAccountId;
  final double amount;
  final String fromCurrency;
  final String toCurrency;
  final double? convertedAmount;
  final double? rate;
  final String note;
  final DateTime date;
  TransactionStatus status;

  Transaction({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
    this.convertedAmount,
    this.rate,
    required this.note,
    required this.date,
    required this.status,
  });
} 