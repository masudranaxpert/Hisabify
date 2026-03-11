import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/categories.dart';
import '../providers/expense_provider.dart';
import '../models/transaction.dart';
import '../widgets/common_widgets.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get weekly data (last 7 days)
  Map<int, double> _getWeeklyData(List<Transaction> transactions, String type) {
    final now = DateTime.now();
    final Map<int, double> data = {};
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      data[6 - i] = transactions
          .where((t) => t.type == type && t.date.day == day.day && t.date.month == day.month && t.date.year == day.year)
          .fold(0.0, (sum, t) => sum + t.amount);
    }
    return data;
  }

  // Get monthly data (last 6 months)
  Map<int, double> _getMonthlyData(List<Transaction> transactions, String type) {
    final now = DateTime.now();
    final Map<int, double> data = {};
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      data[5 - i] = transactions
          .where((t) => t.type == type && t.date.month == month.month && t.date.year == month.year)
          .fold(0.0, (sum, t) => sum + t.amount);
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ExpenseProvider>();
    final allTransactions = provider.transactions;
    final expenses = provider.currentMonthTransactions.where((t) => t.type == 'expense').toList();

    // Category breakdown
    final Map<String, double> categoryTotals = {};
    for (final t in expenses) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalExpense = provider.totalExpense;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 16),
            Text('Statistics', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),

            // Summary cards
            Row(
              children: [
                SummaryCard(
                  title: 'Income', amount: provider.formatAmount(provider.totalIncome),
                  color: AppColors.income, icon: Icons.trending_up_rounded,
                ),
                const SizedBox(width: 12),
                SummaryCard(
                  title: 'Expense', amount: provider.formatAmount(provider.totalExpense),
                  color: AppColors.expense, icon: Icons.trending_down_rounded,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Balance card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text('Balance', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                  ]),
                  Text(
                    provider.formatAmount(provider.balance),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: provider.balance >= 0 ? AppColors.income : AppColors.expense),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tab selector: Weekly / Monthly
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                labelColor: AppColors.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: const [Tab(text: 'Weekly'), Tab(text: 'Monthly')],
              ),
            ),
            const SizedBox(height: 20),

            // Chart
            _tabController.index == 0
                ? _buildWeeklyChart(theme, allTransactions, provider)
                : _buildMonthlyChart(theme, allTransactions, provider),

            const SizedBox(height: 24),

            // Pie chart section
            Text('Expense Breakdown', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),

            if (sortedCategories.isEmpty)
              _buildEmptyState(theme)
            else ...[
              // Pie chart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                height: 220,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 42,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
                            _touchedPieIndex = -1;
                            return;
                          }
                          _touchedPieIndex = response.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sections: List.generate(sortedCategories.length, (i) {
                      final entry = sortedCategories[i];
                      final cat = getCategoryById(entry.key, 'expense');
                      final pct = totalExpense > 0 ? entry.value / totalExpense * 100 : 0;
                      final isTouched = i == _touchedPieIndex;
                      return PieChartSectionData(
                        value: entry.value,
                        title: '${pct.toStringAsFixed(0)}%',
                        titleStyle: TextStyle(fontSize: isTouched ? 14 : 11, fontWeight: FontWeight.w700, color: Colors.white),
                        color: cat.color,
                        radius: isTouched ? 55 : 45,
                        borderSide: isTouched ? BorderSide(color: cat.color.withValues(alpha: 0.6), width: 2) : BorderSide.none,
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Category legend
              ...sortedCategories.map((entry) {
                final cat = getCategoryById(entry.key, 'expense');
                final pct = totalExpense > 0 ? (entry.value / totalExpense * 100) : 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                        child: Icon(cat.icon, color: cat.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text(provider.formatAmount(entry.value), style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct / 100,
                                minHeight: 6,
                                backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                                valueColor: AlwaysStoppedAnimation(cat.color),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${pct.toStringAsFixed(0)}%', style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600, fontSize: 12,
                      )),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.pie_chart_outline, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text('No expense data yet', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
          const SizedBox(height: 4),
          Text('Add transactions to see stats', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(ThemeData theme, List<Transaction> transactions, ExpenseProvider provider) {
    final expenseData = _getWeeklyData(transactions, 'expense');
    final incomeData = _getWeeklyData(transactions, 'income');
    final now = DateTime.now();
    final dayLabels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateFormat('E').format(d).substring(0, 2);
    });

    final maxVal = [...expenseData.values, ...incomeData.values].fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxVal > 0 ? maxVal * 1.2 : 1000,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => theme.cardColor,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  provider.formatAmount(rod.toY),
                  TextStyle(color: rod.color, fontWeight: FontWeight.w600, fontSize: 12),
                );
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxVal > 0 ? maxVal / 4 : 250,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.dividerColor.withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  String label;
                  if (value >= 1000000) {
                    label = '${(value / 1000000).toStringAsFixed(1)}M';
                  } else if (value >= 1000) {
                    label = '${(value / 1000).toStringAsFixed(0)}k';
                  } else {
                    label = value.toStringAsFixed(0);
                  }
                  return Text(label, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= dayLabels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(dayLabels[idx], style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w500)),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(7, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: incomeData[i] ?? 0,
                  color: AppColors.income,
                  width: 8,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                BarChartRodData(
                  toY: expenseData[i] ?? 0,
                  color: AppColors.expense,
                  width: 8,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(ThemeData theme, List<Transaction> transactions, ExpenseProvider provider) {
    final expenseData = _getMonthlyData(transactions, 'expense');
    final incomeData = _getMonthlyData(transactions, 'income');
    final now = DateTime.now();
    final monthLabels = List.generate(6, (i) {
      final d = DateTime(now.year, now.month - 5 + i, 1);
      return DateFormat('MMM').format(d);
    });

    final allValues = [...expenseData.values, ...incomeData.values];
    final maxVal = allValues.fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      height: 220,
      child: LineChart(
        LineChartData(
          maxY: maxVal > 0 ? maxVal * 1.2 : 1000,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxVal > 0 ? maxVal / 4 : 250,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.dividerColor.withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => theme.cardColor,
              tooltipRoundedRadius: 8,
              getTooltipItems: (spots) => spots.map((spot) {
                final color = spot.barIndex == 0 ? AppColors.income : AppColors.expense;
                return LineTooltipItem(
                  provider.formatAmount(spot.y),
                  TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                );
              }).toList(),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  String label;
                  if (value >= 1000000) {
                    label = '${(value / 1000000).toStringAsFixed(1)}M';
                  } else if (value >= 1000) {
                    label = '${(value / 1000).toStringAsFixed(0)}k';
                  } else {
                    label = value.toStringAsFixed(0);
                  }
                  return Text(label, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= monthLabels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(monthLabels[idx], style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w500)),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(6, (i) => FlSpot(i.toDouble(), incomeData[i] ?? 0)),
              color: AppColors.income,
              barWidth: 3,
              isCurved: true,
              curveSmoothness: 0.3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, xPercentage, bar, index) => FlDotCirclePainter(radius: 4, color: AppColors.income, strokeWidth: 2, strokeColor: Colors.white),
              ),
              belowBarData: BarAreaData(show: true, color: AppColors.income.withValues(alpha: 0.08)),
            ),
            LineChartBarData(
              spots: List.generate(6, (i) => FlSpot(i.toDouble(), expenseData[i] ?? 0)),
              color: AppColors.expense,
              barWidth: 3,
              isCurved: true,
              curveSmoothness: 0.3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, xPercentage, bar, index) => FlDotCirclePainter(radius: 4, color: AppColors.expense, strokeWidth: 2, strokeColor: Colors.white),
              ),
              belowBarData: BarAreaData(show: true, color: AppColors.expense.withValues(alpha: 0.08)),
            ),
          ],
        ),
      ),
    );
  }
}
