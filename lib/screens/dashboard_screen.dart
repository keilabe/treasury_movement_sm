import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/treasury_provider.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import 'transaction_history_screen.dart';
import 'transfer_screen.dart';
import 'profile_screen.dart';
import '../widgets/account_card.dart';
import '../widgets/bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    final accounts = context.read<TreasuryProvider>().accounts;
    if (accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
    final selectedAccount = accounts.firstWhere((a) => a.id == _selectedAccountId, orElse: () => accounts.first);

    final List<Widget> _pages = [
      _buildHome(context, selectedAccount, accounts),
      const TransactionHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }

  Widget _buildHome(BuildContext context, Account selectedAccount, List<Account> accounts) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('WalletApp', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedAccount.id,
              items: accounts.map((a) => DropdownMenuItem(
                value: a.id,
                child: Text(a.name),
              )).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedAccountId = val;
                });
              },
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Balance', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(
                    '${selectedAccount.currency} ${selectedAccount.balance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(selectedAccount.name, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Transfer'),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen()));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[100]),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[100]),
                ),
              ],
            ),
            // Scheduled transactions indicator
            if (scheduledTransactionsCount > 0) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
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
                    ElevatedButton(
                      onPressed: () async {
                        final provider = Provider.of<TreasuryProvider>(context, listen: false);
                        await provider.executeDueScheduledTransactions();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Executed $scheduledTransactionsCount scheduled transaction${scheduledTransactionsCount == 1 ? '' : 's'}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('Execute'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text('My Accounts', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: accounts.length,
                itemBuilder: (context, i) => AccountCard(account: accounts[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 