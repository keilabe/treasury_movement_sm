import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/treasury_provider.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../widgets/log_item.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String? selectedAccountId;
  String? selectedCurrency;
  TransactionStatus? selectedStatus;
  String search = '';

  int get scheduledTransactionsCount {
    final provider = Provider.of<TreasuryProvider>(context, listen: false);
    final now = DateTime.now();
    return provider.transactions.where((tx) => 
      tx.status == TransactionStatus.scheduled && !tx.date.isAfter(now)
    ).length;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TreasuryProvider>(context);
    final accounts = provider.accounts;
    final transactions = provider.transactions.where((tx) {
      final accountMatch = selectedAccountId == null || tx.fromAccountId == selectedAccountId || tx.toAccountId == selectedAccountId;
      final currencyMatch = selectedCurrency == null || tx.fromCurrency == selectedCurrency || tx.toCurrency == selectedCurrency;
      final statusMatch = selectedStatus == null || tx.status == selectedStatus;
      final searchMatch = search.isEmpty || tx.note.toLowerCase().contains(search.toLowerCase());
      return accountMatch && currencyMatch && statusMatch && searchMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: SafeArea(
        child: Column(
          children: [
            // Execute scheduled transactions button
            if (scheduledTransactionsCount > 0)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$scheduledTransactionsCount scheduled transaction${scheduledTransactionsCount == 1 ? '' : 's'} ready to execute',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Execute Due Transactions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          await provider.executeDueScheduledTransactions();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Executed $scheduledTransactionsCount scheduled transaction${scheduledTransactionsCount == 1 ? '' : 's'}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: DropdownButton<String>(
                        isDense: true,
                        value: selectedAccountId,
                        hint: const Text('Account', style: TextStyle(fontSize: 12)),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Accounts', style: TextStyle(fontSize: 12))),
                          ...accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name, style: const TextStyle(fontSize: 12)))).toList(),
                        ],
                        onChanged: (val) => setState(() => selectedAccountId = val),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 120,
                      child: DropdownButton<String>(
                        isDense: true,
                        value: selectedCurrency,
                        hint: const Text('Currency', style: TextStyle(fontSize: 12)),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Currencies', style: TextStyle(fontSize: 12))),
                          ...['USD', 'KES', 'NGN'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                        ],
                        onChanged: (val) => setState(() => selectedCurrency = val),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 120,
                      child: DropdownButton<TransactionStatus>(
                        isDense: true,
                        value: selectedStatus,
                        hint: const Text('Status', style: TextStyle(fontSize: 12)),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Statuses', style: TextStyle(fontSize: 12))),
                          ...TransactionStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name[0].toUpperCase() + s.name.substring(1), style: const TextStyle(fontSize: 12)))).toList(),
                        ],
                        onChanged: (val) => setState(() => selectedStatus = val),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 140,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(fontSize: 12),
                        onChanged: (val) => setState(() => search = val),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: transactions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No transactions found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, i) => LogItem(
                      transaction: transactions[i],
                      accounts: accounts,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
} 