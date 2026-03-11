import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/transaction.dart';
import '../constants/categories.dart';

class ExportService {
  // Get the export directory based on mode
  static Future<Directory> _getExportDir(String mode, {String customPath = ''}) async {
    switch (mode) {
      case 'downloads':
        final dir = Directory('/storage/emulated/0/Download');
        if (await dir.exists()) return dir;
        return await getTemporaryDirectory();
      case 'documents':
        final dir = Directory('/storage/emulated/0/Documents');
        if (await dir.exists()) return dir;
        return await getApplicationDocumentsDirectory();
      case 'custom':
        if (customPath.isNotEmpty) {
          final dir = Directory(customPath);
          if (await dir.exists()) return dir;
        }
        return await getTemporaryDirectory();
      default:
        return await getTemporaryDirectory();
    }
  }

  // Get display name for export mode
  static String getModeName(String mode, {String customPath = ''}) {
    switch (mode) {
      case 'downloads':
        return 'Downloads Folder';
      case 'documents':
        return 'Documents Folder';
      case 'custom':
        if (customPath.isNotEmpty) {
          // Show last 2 folders of the path
          final parts = customPath.split('/');
          return parts.length > 2 ? '.../${parts[parts.length - 2]}/${parts.last}' : customPath;
        }
        return 'Choose Folder';
      default:
        return 'Share via System';
    }
  }

  // Export transactions to CSV
  static Future<String> exportCSV(List<Transaction> transactions, {String mode = 'share', String customPath = ''}) async {
    if (transactions.isEmpty) {
      throw Exception('No transactions to export');
    }

    List<List<dynamic>> rows = [];
    rows.add(['Date', 'Type', 'Category', 'Amount', 'Note']);

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    for (final t in transactions) {
      final cat = getCategoryById(t.category, t.type);
      rows.add([
        dateFormat.format(t.date),
        t.type.toUpperCase(),
        cat.name,
        t.amount.toStringAsFixed(2),
        t.note ?? '',
      ]);
    }

    final totalIncome = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    rows.add([]);
    rows.add(['SUMMARY']);
    rows.add(['Total Income', '', '', totalIncome.toStringAsFixed(2)]);
    rows.add(['Total Expense', '', '', totalExpense.toStringAsFixed(2)]);
    rows.add(['Balance', '', '', (totalIncome - totalExpense).toStringAsFixed(2)]);

    final csv = const ListToCsvConverter().convert(rows);

    final dir = await _getExportDir(mode, customPath: customPath);
    final date = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final file = File('${dir.path}/expense_tracker_$date.csv');
    await file.writeAsString(csv);

    if (mode == 'share') {
      await Share.shareXFiles([XFile(file.path)], subject: 'Expense Tracker - CSV');
      return 'Shared successfully';
    }
    return 'Saved to: ${file.path}';
  }

  // Export full backup to JSON
  static Future<String> exportJSON({
    required List<Transaction> transactions,
    required double monthlyBudget,
    required String currency,
    String mode = 'share',
    String customPath = '',
  }) async {
    if (transactions.isEmpty) {
      throw Exception('No transactions to export');
    }

    final data = {
      'appVersion': '1.0.0',
      'exportDate': DateTime.now().toIso8601String(),
      'currency': currency,
      'monthlyBudget': monthlyBudget,
      'transactionCount': transactions.length,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };

    final json = const JsonEncoder.withIndent('  ').convert(data);

    final dir = await _getExportDir(mode, customPath: customPath);
    final date = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final file = File('${dir.path}/expense_tracker_backup_$date.json');
    await file.writeAsString(json);

    if (mode == 'share') {
      await Share.shareXFiles([XFile(file.path)], subject: 'Expense Tracker - Backup');
      return 'Shared successfully';
    }
    return 'Saved to: ${file.path}';
  }
}
