import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/services/export_service.dart';
import '../providers/expense_provider.dart';
import '../widgets/app_notification.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  void _exportCSV(BuildContext context) async {
    final provider = context.read<ExpenseProvider>();
    if (provider.transactions.isEmpty) {
      if (context.mounted) AppNotification.info(context, 'Add some transactions first to export');
      return;
    }
    try {
      final result = await ExportService.exportCSV(provider.transactions, mode: provider.exportMode, customPath: provider.customExportPath);
      if (context.mounted) AppNotification.success(context, result);
    } catch (e) {
      if (context.mounted) AppNotification.error(context, 'Export failed. Please try again');
    }
  }

  void _exportJSON(BuildContext context) async {
    final provider = context.read<ExpenseProvider>();
    if (provider.transactions.isEmpty) {
      if (context.mounted) AppNotification.info(context, 'Add some transactions first to export');
      return;
    }
    try {
      final result = await ExportService.exportJSON(
        transactions: provider.transactions,
        monthlyBudget: provider.monthlyBudget,
        currency: provider.currency,
        mode: provider.exportMode,
        customPath: provider.customExportPath,
      );
      if (context.mounted) AppNotification.success(context, result);
    } catch (e) {
      if (context.mounted) AppNotification.error(context, 'Export failed. Please try again');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 16),
            Text('Tools', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),

            // Export
            _SectionLabel('EXPORT'),
            const SizedBox(height: 8),
            Row(
              children: [
                _ToolCard(icon: Icons.description_outlined, title: 'Export CSV', subtitle: 'Excel / Sheets', color: const Color(0xFF22C55E), theme: theme, onTap: () => _exportCSV(context)),
                const SizedBox(width: 12),
                _ToolCard(icon: Icons.data_object_rounded, title: 'Backup JSON', subtitle: 'Full backup', color: const Color(0xFF3B82F6), theme: theme, onTap: () => _exportJSON(context)),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Access
            _SectionLabel('QUICK ACCESS'),
            const SizedBox(height: 8),
            Row(
              children: [
                _ToolCard(icon: Icons.wallet_rounded, title: 'Budget', subtitle: provider.formatAmount(provider.monthlyBudget), color: AppColors.primary, theme: theme, onTap: () => Navigator.pushNamed(context, '/budget')),
                const SizedBox(width: 12),
                _ToolCard(icon: Icons.settings_rounded, title: 'Settings', subtitle: 'Theme & more', color: const Color(0xFF06B6D4), theme: theme, onTap: () => Navigator.pushNamed(context, '/settings')),
              ],
            ),
            const SizedBox(height: 20),

            // Productivity
            _SectionLabel('PRODUCTIVITY'),
            const SizedBox(height: 8),
            Row(
              children: [
                _ToolCard(icon: Icons.self_improvement_rounded, title: 'Habits', subtitle: 'Track & Timer', color: const Color(0xFF7C3AED), theme: theme, onTap: () => Navigator.pushNamed(context, '/habits')),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(
      fontSize: 11, fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
    ));
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon, required this.title, required this.subtitle,
    required this.color, required this.theme, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
            ],
          ),
        ),
      ),
    );
  }
}
