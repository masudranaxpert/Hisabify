import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  double _monthlyBudget = 50000;
  String _currency = '৳';
  String _exportMode = 'share';
  String _customExportPath = '';

  List<Transaction> get transactions => _transactions;
  double get monthlyBudget => _monthlyBudget;
  String get currency => _currency;
  String get exportMode => _exportMode;
  String get customExportPath => _customExportPath;

  // Current month transactions
  List<Transaction> get currentMonthTransactions {
    final now = DateTime.now();
    return _transactions.where((t) =>
      t.date.month == now.month && t.date.year == now.year
    ).toList();
  }

  double get totalIncome => currentMonthTransactions
      .where((t) => t.type == 'income')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => currentMonthTransactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  ExpenseProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load transactions
    final data = prefs.getString('transactions');
    if (data != null) {
      final List<dynamic> list = jsonDecode(data);
      _transactions = list.map((e) => Transaction.fromJson(e)).toList();
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    }

    // Load budget
    _monthlyBudget = prefs.getDouble('monthlyBudget') ?? 50000;

    // Load currency
    _currency = prefs.getString('currency') ?? '৳';

    // Load export mode
    _exportMode = prefs.getString('exportMode') ?? 'share';

    // Load custom export path
    _customExportPath = prefs.getString('customExportPath') ?? '';

    notifyListeners();
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_transactions.map((t) => t.toJson()).toList());
    await prefs.setString('transactions', data);
  }

  void addTransaction(Transaction t) {
    _transactions.insert(0, t);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    _saveTransactions();
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    _saveTransactions();
    notifyListeners();
  }

  void updateTransaction(Transaction updated) {
    final index = _transactions.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _transactions[index] = updated;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      _saveTransactions();
      notifyListeners();
    }
  }

  Future<void> setBudget(double amount) async {
    _monthlyBudget = amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthlyBudget', amount);
    notifyListeners();
  }

  Future<void> setCurrency(String symbol) async {
    _currency = symbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', symbol);
    notifyListeners();
  }

  String formatAmount(double amount) {
    if (amount >= 1000000) {
      return '$_currency${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$_currency${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}k';
    }
    return '$_currency${amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2)}';
  }

  Future<void> setExportMode(String mode, {String? customPath}) async {
    _exportMode = mode;
    if (customPath != null) _customExportPath = customPath;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('exportMode', mode);
    if (customPath != null) await prefs.setString('customExportPath', customPath);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _transactions.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('transactions');
    notifyListeners();
  }
}
