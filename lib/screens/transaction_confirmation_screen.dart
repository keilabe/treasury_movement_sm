import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/account.dart';

class TransactionConfirmationScreen extends StatelessWidget {
  final Transaction transaction;
  final Account fromAccount;
  final Account toAccount;

  const TransactionConfirmationScreen({
    Key? key,
    required this.transaction,
    required this.fromAccount,
    required this.toAccount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isScheduled = transaction.status == TransactionStatus.scheduled;
    final isCompleted = transaction.status == TransactionStatus.completed;
    
    return Scaffold(
      appBar: AppBar(title: Text(isScheduled ? 'Transaction Scheduled' : 'Transaction Successful')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isScheduled ? Icons.schedule : Icons.check_circle,
                  color: isScheduled ? Colors.orange : Colors.green,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  isScheduled ? 'Transfer Scheduled!' : 'Transfer Successful!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isScheduled ? Colors.orange[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isScheduled ? Colors.orange : Colors.green,
                    ),
                  ),
                  child: Text(
                    isScheduled ? 'Scheduled' : 'Completed',
                    style: TextStyle(
                      color: isScheduled ? Colors.orange[700] : Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('From: ${fromAccount.name} (${fromAccount.currency})'),
                Text('To: ${toAccount.name} (${toAccount.currency})'),
                const SizedBox(height: 16),
                Text('Amount: ${transaction.fromCurrency} ${transaction.amount.toStringAsFixed(2)}'),
                if (transaction.convertedAmount != null)
                  Text('Converted: ${transaction.toCurrency} ${transaction.convertedAmount!.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                Text('Date: ${transaction.date.toLocal().toString().split(' ')[0]}'),
                if (isScheduled)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Note: Balances will be updated when the transaction is executed',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text('Transaction ID: ${transaction.id}'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}