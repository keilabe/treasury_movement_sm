import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/treasury_provider.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../widgets/bottom_nav.dart';
import '../screens/transaction_confirmation_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String? fromAccountId;
  String? toAccountId;
  double amount = 0.0;
  String note = '';
  DateTime selectedDate = DateTime.now();
  int _selectedIndex = 0;

  bool get isScheduledTransaction => selectedDate.isAfter(DateTime.now());

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TreasuryProvider>(context);
    final accounts = provider.accounts;
    final fromAccount = fromAccountId != null ? accounts.firstWhere((a) => a.id == fromAccountId) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Money')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'From Account'),
                  value: fromAccountId,
                  items: accounts.map((a) => DropdownMenuItem(
                    value: a.id,
                    child: Text(a.name),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      fromAccountId = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'To Account'),
                  value: toAccountId,
                  items: accounts.where((a) => a.id != fromAccountId).map((a) => DropdownMenuItem(
                    value: a.id,
                    child: Text(a.name),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      toAccountId = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: fromAccount?.currency != null ? '${fromAccount!.currency} ' : '',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      amount = double.tryParse(val) ?? 0.0;
                    });
                  },
                ),
                if (fromAccount != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                    child: Text('Available balance: ${fromAccount.currency} ${fromAccount.balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Note (Optional)'),
                  onChanged: (val) {
                    setState(() {
                      note = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Date picker with better UX
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Transaction Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedDate.toLocal().toString().split(' ')[0],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Status indicator for scheduled vs immediate transactions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isScheduledTransaction ? Colors.orange[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isScheduledTransaction ? Colors.orange : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isScheduledTransaction ? Icons.schedule : Icons.check_circle,
                        color: isScheduledTransaction ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isScheduledTransaction 
                            ? 'This transaction will be scheduled for ${selectedDate.toLocal().toString().split(' ')[0]}'
                            : 'This transaction will be executed immediately',
                          style: TextStyle(
                            color: isScheduledTransaction ? Colors.orange[700] : Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.blue[50],
                  child: ListTile(
                    title: const Text('Transfer Summary'),
                    subtitle: Text('From: ${fromAccountId != null ? accounts.firstWhere((a) => a.id == fromAccountId).name : '-'}\nTo: ${toAccountId != null ? accounts.firstWhere((a) => a.id == toAccountId).name : '-'}\nAmount: $amount\nDate: ${selectedDate.toLocal().toString().split(' ')[0]}\nStatus: ${isScheduledTransaction ? 'Scheduled' : 'Immediate'}'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(isScheduledTransaction ? Icons.schedule : Icons.send),
                    label: Text(isScheduledTransaction ? 'Schedule Transfer' : 'Transfer Money'),
                    onPressed: fromAccountId != null && toAccountId != null && amount > 0
                        ? () async {
        await provider.transfer(
          fromAccountId: fromAccountId!,
          toAccountId: toAccountId!,
          amount: amount,
          note: note,
          date: selectedDate,
        );
        final fromAccount = provider.accounts.firstWhere((a) => a.id == fromAccountId);
        final toAccount = provider.accounts.firstWhere((a) => a.id == toAccountId);
        final lastTx = provider.transactions.last;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionConfirmationScreen(
              transaction: lastTx,
              fromAccount: fromAccount,
              toAccount: toAccount,
            ),
          ),
        );
      }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (i) {
          Navigator.pop(context);
        },
      ),
    );
  }
} 