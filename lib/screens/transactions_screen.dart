import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../providers/expense_provider.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/app_notification.dart';
import '../models/transaction.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _filter = 'all'; // 'all', 'income', 'expense'
  String _searchQuery = '';
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> _applyFilters(List<Transaction> transactions) {
    var filtered = transactions.toList();

    // Type filter
    if (_filter == 'income') {
      filtered = filtered.where((t) => t.type == 'income').toList();
    } else if (_filter == 'expense') {
      filtered = filtered.where((t) => t.type == 'expense').toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        final note = (t.note ?? '').toLowerCase();
        final category = t.category.toLowerCase();
        final amount = t.amount.toString();
        return note.contains(q) || category.contains(q) || amount.contains(q);
      }).toList();
    }

    return filtered;
  }

  // Group transactions by date
  Map<String, List<Transaction>> _groupByDate(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final t in transactions) {
      final date = DateTime(t.date.year, t.date.month, t.date.day);
      String key;
      if (date == today) {
        key = 'Today';
      } else if (date == yesterday) {
        key = 'Yesterday';
      } else if (date.year == now.year) {
        key = DateFormat('d MMM').format(t.date);
      } else {
        key = DateFormat('d MMM yyyy').format(t.date);
      }
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(t);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ExpenseProvider>();
    final all = provider.transactions;
    final filtered = _applyFilters(all);
    final grouped = _groupByDate(filtered);

    // Count for each type
    final incomeCount = all.where((t) => t.type == 'income').length;
    final expenseCount = all.where((t) => t.type == 'expense').length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Transactions', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  // Search toggle
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showSearch = !_showSearch;
                        if (!_showSearch) {
                          _searchController.clear();
                          _searchQuery = '';
                        }
                      });
                    },
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: _showSearch ? AppColors.primary.withValues(alpha: 0.12) : theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _showSearch ? AppColors.primary.withValues(alpha: 0.3) : theme.dividerColor),
                      ),
                      child: Icon(
                        _showSearch ? Icons.close : Icons.search_rounded,
                        size: 20,
                        color: _showSearch ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search by note, category, amount...',
                    hintStyle: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                    prefixIcon: Icon(Icons.search, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: theme.dividerColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: theme.dividerColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary)),
                  ),
                ),
              ),

            // Filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    count: all.length,
                    isActive: _filter == 'all',
                    color: AppColors.primary,
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Income',
                    count: incomeCount,
                    isActive: _filter == 'income',
                    color: AppColors.income,
                    onTap: () => setState(() => _filter = 'income'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Expense',
                    count: expenseCount,
                    isActive: _filter == 'expense',
                    color: AppColors.expense,
                    onTap: () => setState(() => _filter = 'expense'),
                  ),
                ],
              ),
            ),

            // Transaction list
            if (all.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 56, color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
                      const SizedBox(height: 12),
                      Text('No transactions yet', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                      const SizedBox(height: 4),
                      Text('Tap + to add one', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                    ],
                  ),
                ),
              )
            else if (filtered.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list_off_rounded, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
                      const SizedBox(height: 12),
                      Text('No matching transactions', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                      const SizedBox(height: 4),
                      Text('Try a different filter', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: grouped.length,
                  itemBuilder: (ctx, index) {
                    final dateKey = grouped.keys.elementAt(index);
                    final dayTransactions = grouped[dateKey]!;
                    final dayTotal = dayTransactions.fold<double>(
                      0.0,
                      (sum, t) => t.type == 'expense' ? sum - t.amount : sum + t.amount,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dateKey, style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              )),
                              Text(
                                '${dayTotal >= 0 ? '+' : ''}${provider.formatAmount(dayTotal.abs())}',
                                style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600,
                                  color: dayTotal >= 0 ? AppColors.income : AppColors.expense,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Transactions for this day
                        ...dayTransactions.map((t) => Dismissible(
                          key: Key(t.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.expense.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
                          ),
                          confirmDismiss: (direction) => _confirmDelete(context),
                          onDismissed: (direction) {
                            provider.deleteTransaction(t.id);
                            AppNotification.info(context, 'Transaction deleted');
                          },
                          child: TransactionTile(
                            transaction: t,
                            onLongPress: () => _showDeleteDialog(context, provider, t.id),
                          ),
                        )),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete?'),
        content: const Text('Remove this transaction?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ExpenseProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete?'),
        content: const Text('Remove this transaction?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.deleteTransaction(id);
              Navigator.pop(ctx);
              AppNotification.info(context, 'Transaction deleted');
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.12) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.4) : Theme.of(context).dividerColor,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            )),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? color.withValues(alpha: 0.15) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isActive ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
