import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/expense_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onSeeAll;
  const HomeScreen({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final theme = Theme.of(context);

    final recent = provider.transactions.take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hisabify',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.settings_outlined, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Balance Card
            const BalanceCard(),

            const SizedBox(height: 24),

            // Budget Progress
            _BudgetProgress(provider: provider, theme: theme),

            const SizedBox(height: 24),

            // Recent Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text('See All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (recent.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.add_circle_outline, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                    const SizedBox(height: 12),
                    Text('No transactions yet', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                  ],
                ),
              )
            else
              ...recent.map((t) => TransactionTile(transaction: t)),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  final ExpenseProvider provider;
  final ThemeData theme;

  const _BudgetProgress({required this.provider, required this.theme});

  @override
  Widget build(BuildContext context) {
    final spent = provider.totalExpense;
    final budget = provider.monthlyBudget;
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final remaining = (budget - spent).clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Budget', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: progress > 0.9 ? AppColors.expense : AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(
                progress > 0.9 ? AppColors.expense : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${provider.formatAmount(spent)}',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
              Text(
                'Left: ${provider.formatAmount(remaining)}',
                style: TextStyle(fontSize: 12, color: AppColors.income, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
