import 'package:flutter/material.dart';
import '../core/constants/categories.dart';
import '../models/transaction.dart' as model;
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class TransactionTile extends StatelessWidget {
  final model.Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = getCategoryById(transaction.category, transaction.type);
    final isExpense = transaction.type == 'expense';
    final provider = context.read<ExpenseProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(category.icon, color: category.color, size: 22),
        ),
        title: Text(
          category.name,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          transaction.note ?? 'No description',
          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '${isExpense ? '-' : '+'}${provider.formatAmount(transaction.amount)}',
          style: TextStyle(
            color: isExpense ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
