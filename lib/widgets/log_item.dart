import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/account.dart';

class LogItem extends StatelessWidget {
  final Transaction transaction;
  final List<Account> accounts;
  const LogItem({Key? key, required this.transaction, required this.accounts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fromAccount = accounts.firstWhere((a) => a.id == transaction.fromAccountId, orElse: () => Account(id: '', name: 'Unknown', currency: '', balance: 0));
    final toAccount = accounts.firstWhere((a) => a.id == transaction.toAccountId, orElse: () => Account(id: '', name: 'Unknown', currency: '', balance: 0));
    final isCompleted = transaction.status == TransactionStatus.completed;
    final isScheduled = transaction.status == TransactionStatus.scheduled;
    final color = isCompleted ? Colors.green : isScheduled ? Colors.orange : Colors.grey;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(Icons.swap_horiz, color: color),
        title: Text('${fromAccount.name} → ${toAccount.name}'),
        subtitle: Text('${transaction.date.toLocal().toString().split(' ')[0]}\n${transaction.note}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              (transaction.fromCurrency == transaction.toCurrency)
                  ? '${transaction.fromCurrency} ${transaction.amount.toStringAsFixed(2)}'
                  : '${transaction.fromCurrency} ${transaction.amount.toStringAsFixed(2)} → ${transaction.toCurrency} ${transaction.convertedAmount?.toStringAsFixed(2) ?? ''}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isCompleted ? 'Completed' : isScheduled ? 'Scheduled' : '',
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        ),
      ),
    );
  }
} 