import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../core/theme/app_theme.dart';
import '../core/services/export_service.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_notification.dart';
import '../habits/providers/habits_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showCurrencyPicker = false;

  static const currencies = [
    {'symbol': '৳', 'name': 'BDT (Taka)'},
    {'symbol': '\$', 'name': 'USD (Dollar)'},
    {'symbol': '€', 'name': 'EUR (Euro)'},
    {'symbol': '₹', 'name': 'INR (Rupee)'},
    {'symbol': '£', 'name': 'GBP (Pound)'},
    {'symbol': '¥', 'name': 'JPY (Yen)'},
  ];

  void _showExportModePicker(BuildContext context, ExpenseProvider expense) async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();
      if (result != null && context.mounted) {
        expense.setExportMode('custom', customPath: result);
        AppNotification.success(context, 'Export folder: $result');
      }
    } catch (e) {
      if (context.mounted) {
        AppNotification.error(context, 'Please restart the app to use folder picker');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expense = context.watch<ExpenseProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Export
          _SectionLabel('EXPORT'),
          _Card(
            theme: theme,
            child: ListTile(
              leading: _IconBox(Icons.folder_outlined, const Color(0xFFF59E0B)),
              title: const Text('Export Location'),
              subtitle: Text(ExportService.getModeName(expense.exportMode, customPath: expense.customExportPath)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showExportModePicker(context, expense),
            ),
          ),
          const SizedBox(height: 20),

          // Theme
          _SectionLabel('THEME'),
          _Card(
            theme: theme,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _ThemeOption(
                    icon: Icons.dark_mode_rounded,
                    label: 'Dark',
                    isActive: themeProvider.themeMode == ThemeMode.dark,
                    onTap: () => themeProvider.setTheme(ThemeMode.dark),
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _ThemeOption(
                    icon: Icons.light_mode_rounded,
                    label: 'Light',
                    isActive: themeProvider.themeMode == ThemeMode.light,
                    onTap: () => themeProvider.setTheme(ThemeMode.light),
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _ThemeOption(
                    icon: Icons.phone_android_rounded,
                    label: 'System',
                    isActive: themeProvider.themeMode == ThemeMode.system,
                    onTap: () => themeProvider.setTheme(ThemeMode.system),
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Currency
          _SectionLabel('CURRENCY'),
          _Card(
            theme: theme,
            child: Column(
              children: [
                ListTile(
                  leading: _IconBox(Icons.attach_money_rounded, const Color(0xFF06B6D4)),
                  title: const Text('Currency'),
                  subtitle: Text(currencies.firstWhere((c) => c['symbol'] == expense.currency)['name'] ?? 'BDT'),
                  trailing: Icon(_showCurrencyPicker ? Icons.expand_less : Icons.expand_more),
                  onTap: () => setState(() => _showCurrencyPicker = !_showCurrencyPicker),
                ),
                if (_showCurrencyPicker) ...[
                  Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3), indent: 56),
                  ...currencies.map((c) => ListTile(
                    leading: Text(c['symbol']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    title: Text(c['name']!),
                    trailing: expense.currency == c['symbol']
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                    onTap: () {
                      expense.setCurrency(c['symbol']!);
                      setState(() => _showCurrencyPicker = false);
                    },
                  )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Data
          _SectionLabel('DATA'),
          _Card(
            theme: theme,
            child: Column(
              children: [
                ListTile(
                  leading: _IconBox(Icons.analytics_outlined, AppColors.primary),
                  title: const Text('Total Transactions'),
                  subtitle: Text('${expense.transactions.length} recorded'),
                ),
                Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3), indent: 56),
                ListTile(
                  leading: _IconBox(Icons.receipt_long_outlined, const Color(0xFFF59E0B)),
                  title: const Text('Clear Expense Data'),
                  subtitle: const Text('Only remove transactions'),
                  onTap: () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Clear Expense Data?'),
                      content: const Text('This will remove all transactions. Habits will not be affected.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            expense.clearAll();
                            Navigator.pop(ctx);
                            AppNotification.success(context, 'Expense data cleared');
                          },
                          child: const Text('Clear', style: TextStyle(color: AppColors.expense)),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3), indent: 56),
                ListTile(
                  leading: _IconBox(Icons.delete_forever_outlined, AppColors.expense),
                  title: const Text('Clear All Data'),
                  subtitle: const Text('Remove transactions + habits'),
                  onTap: () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Clear Everything?'),
                      content: const Text('This will delete all transactions AND habits permanently.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            expense.clearAll();
                            context.read<HabitsProvider>().clearAll();
                            Navigator.pop(ctx);
                            AppNotification.success(context, 'All data cleared');
                          },
                          child: const Text('Clear All', style: TextStyle(color: AppColors.expense)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // About
          _SectionLabel('ABOUT'),
          _Card(
            theme: theme,
            child: Column(
              children: [
                ListTile(
                  leading: _IconBox(Icons.info_outline_rounded, const Color(0xFF6B7280)),
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                ),
                Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3), indent: 56),
                ListTile(
                  leading: _IconBox(Icons.star_outline_rounded, const Color(0xFFF59E0B)),
                  title: const Text('Rate App'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          Center(child: Text('Hisabify — Made with ❤️ by Masud Rana', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 12))),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
      )),
    );
  }
}

class _Card extends StatelessWidget {
  final ThemeData theme;
  final Widget child;
  const _Card({required this.theme, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBox(this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ThemeOption({
    required this.icon, required this.label, required this.isActive,
    required this.onTap, required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.12)
                : theme.colorScheme.onSurface.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: isActive ? Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5) : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 22),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(
                fontSize: 12,
                color: isActive ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
