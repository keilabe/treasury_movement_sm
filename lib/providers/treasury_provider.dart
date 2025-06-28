import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/account.dart';
import '../models/transaction.dart';
import 'dart:math';

class TreasuryProvider extends ChangeNotifier {
  // Static FX rates
  static const Map<String, double> fxRates = {
    'KES-USD': 0.0078,
    'KES-NGN': 1.2,
    'USD-KES': 128.0,
    'USD-NGN': 150.0,
    'NGN-KES': 0.83,
    'NGN-USD': 0.0067,
  };

  List<Account> accounts = [];
  List<Transaction> transactions = [];

  TreasuryProvider() {
    fetchAccounts();
    fetchTransactions();
  }

  // Load accounts from Firestore
  Future<void> fetchAccounts() async {
    final snapshot = await firestore.FirebaseFirestore.instance.collection('accounts').get();
    accounts = snapshot.docs.map((doc) => Account(
      id: doc.id,
      name: doc['name'],
      currency: doc['currency'],
      balance: (doc['balance'] as num).toDouble(),
    )).toList();
    notifyListeners();
  }

  // Save account changes to Firestore
  Future<void> updateAccount(Account account) async {
    await firestore.FirebaseFirestore.instance.collection('accounts').doc(account.id).update({
      'name': account.name,
      'currency': account.currency,
      'balance': account.balance,
    });
  }

  // Load transactions from Firestore
  Future<void> fetchTransactions() async {
    final snapshot = await firestore.FirebaseFirestore.instance.collection('transactions').get();
    transactions = snapshot.docs.map((doc) => Transaction(
      id: doc.id,
      fromAccountId: doc['fromAccountId'],
      toAccountId: doc['toAccountId'],
      amount: (doc['amount'] as num).toDouble(),
      fromCurrency: doc['fromCurrency'],
      toCurrency: doc['toCurrency'],
      convertedAmount: (doc['convertedAmount'] as num?)?.toDouble(),
      rate: (doc['rate'] as num?)?.toDouble(),
      note: doc['note'],
      date: (doc['date'] as firestore.Timestamp).toDate(),
      status: TransactionStatus.values.firstWhere((e) => e.name == doc['status']),
    )).toList();
    notifyListeners();
  }

  // Save a transaction to Firestore
  Future<void> addTransaction(Transaction tx) async {
    await firestore.FirebaseFirestore.instance.collection('transactions').add({
      'fromAccountId': tx.fromAccountId,
      'toAccountId': tx.toAccountId,
      'amount': tx.amount,
      'fromCurrency': tx.fromCurrency,
      'toCurrency': tx.toCurrency,
      'convertedAmount': tx.convertedAmount,
      'rate': tx.rate,
      'note': tx.note,
      'date': tx.date,
      'status': tx.status.name,
    });
  }

  /// Transfer method with Firestore sync
  /// 
  /// This method handles both immediate and scheduled transactions:
  /// - If the date is in the future, the transaction is marked as 'scheduled' 
  ///   and balances are NOT updated immediately
  /// - If the date is today or in the past, the transaction is marked as 'completed'
  ///   and balances are updated immediately
  /// 
  /// Scheduled transactions can be executed later using executeDueScheduledTransactions()
  Future<void> transfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String note,
    required DateTime date,
  }) async {
    debugPrint('Transfer started: from $fromAccountId to $toAccountId, amount: $amount, note: $note, date: $date');
    try {
      final fromAccount = accounts.firstWhere((a) => a.id == fromAccountId);
      final toAccount = accounts.firstWhere((a) => a.id == toAccountId);
      final isFX = fromAccount.currency != toAccount.currency;
      double? convertedAmount;
      double? rate;
      String fxKey = '${fromAccount.currency}-${toAccount.currency}';
      if (isFX) {
        rate = fxRates[fxKey];
        if (rate == null) throw Exception('FX rate not found');
        convertedAmount = amount * rate;
      }
      final now = DateTime.now();
      final isFuture = date.isAfter(now);
      final status = isFuture ? TransactionStatus.scheduled : TransactionStatus.completed;
      
      debugPrint('Transaction will be ${isFuture ? 'scheduled' : 'completed immediately'}');
      
      final tx = Transaction(
        id: Random().nextInt(1000000).toString(),
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        fromCurrency: fromAccount.currency,
        toCurrency: toAccount.currency,
        convertedAmount: convertedAmount,
        rate: rate,
        note: note,
        date: date,
        status: status,
      );
      transactions.add(tx);
      
      // Only update balances for immediate transactions
      if (!isFuture) {
        _executeTransaction(tx);
        await updateAccount(fromAccount);
        await updateAccount(toAccount);
        debugPrint('Balances updated immediately for transaction ${tx.id}');
      } else {
        debugPrint('Transaction ${tx.id} scheduled for ${date.toLocal().toString().split(' ')[0]}');
      }
      
      await addTransaction(tx);
      debugPrint('Transfer successful: ${tx.id}');
      notifyListeners();
    } catch (e, stack) {
      debugPrint('Transfer failed: $e\n$stack');
      rethrow;
    }
  }

  /// Execute scheduled transactions that are due (date is today or earlier)
  /// 
  /// This method:
  /// 1. Finds all scheduled transactions with dates <= today
  /// 2. Updates account balances for those transactions
  /// 3. Changes their status from 'scheduled' to 'completed'
  /// 4. Updates both local state and Firestore
  /// 
  /// Use this method to simulate the passage of time or to execute
  /// scheduled transactions when the user changes their device date
  Future<void> executeDueScheduledTransactions() async {
    final now = DateTime.now();
    final dueTransactions = transactions.where((t) => 
      t.status == TransactionStatus.scheduled && !t.date.isAfter(now)
    ).toList();
    
    debugPrint('Found ${dueTransactions.length} scheduled transactions due for execution');
    
    if (dueTransactions.isEmpty) {
      debugPrint('No scheduled transactions to execute');
      return;
    }
    
    try {
      for (var tx in dueTransactions) {
        debugPrint('Executing scheduled transaction ${tx.id} from ${tx.fromAccountId} to ${tx.toAccountId}');
        
        // Execute the transaction (update balances)
        _executeTransaction(tx);
        
        // Update status to completed
        tx.status = TransactionStatus.completed;
        
        // Update accounts in Firestore
        final fromAccount = accounts.firstWhere((a) => a.id == tx.fromAccountId);
        final toAccount = accounts.firstWhere((a) => a.id == tx.toAccountId);
        await updateAccount(fromAccount);
        await updateAccount(toAccount);
        
        // Update transaction status in Firestore
        await firestore.FirebaseFirestore.instance
          .collection('transactions')
          .doc(tx.id)
          .update({'status': 'completed'});
        
        debugPrint('Successfully executed transaction ${tx.id}');
      }
      
      notifyListeners();
      debugPrint('All due scheduled transactions executed successfully');
    } catch (e, stack) {
      debugPrint('Error executing scheduled transactions: $e\n$stack');
      rethrow;
    }
  }

  /// Internal method to execute a transaction by updating account balances
  /// This method does NOT update Firestore - that's handled by the calling method
  void _executeTransaction(Transaction tx) {
    final fromAccount = accounts.firstWhere((a) => a.id == tx.fromAccountId);
    final toAccount = accounts.firstWhere((a) => a.id == tx.toAccountId);
    
    debugPrint('Executing transaction: ${fromAccount.currency} ${tx.amount} from ${fromAccount.name} to ${toAccount.name}');
    
    if (fromAccount.currency == toAccount.currency) {
      // Same currency transfer
      fromAccount.balance -= tx.amount;
      toAccount.balance += tx.amount;
      debugPrint('Same currency transfer: ${fromAccount.name} balance now ${fromAccount.balance}, ${toAccount.name} balance now ${toAccount.balance}');
    } else {
      // FX transfer
      fromAccount.balance -= tx.amount;
      toAccount.balance += tx.convertedAmount ?? 0;
      debugPrint('FX transfer: ${fromAccount.name} balance now ${fromAccount.balance}, ${toAccount.name} balance now ${toAccount.balance}');
    }
  }
} 