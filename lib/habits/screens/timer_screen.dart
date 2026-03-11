import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Text('Timer', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 12),

        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            tabs: const [
              Tab(text: 'Stopwatch', height: 36),
              Tab(text: 'Countdown', height: 36),
              Tab(text: 'Interval', height: 36),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _StopwatchTab(),
              _CountdownTab(),
              _IntervalTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ===== STOPWATCH TAB =====
class _StopwatchTab extends StatefulWidget {
  const _StopwatchTab();
  @override
  State<_StopwatchTab> createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<_StopwatchTab> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<Duration> _laps = [];

  void _startStop() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
    } else {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 30), (_) => setState(() {}));
    }
    setState(() {});
  }

  void _lap() {
    if (_stopwatch.isRunning) {
      setState(() => _laps.insert(0, _stopwatch.elapsed));
    }
  }

  void _reset() {
    _stopwatch.stop();
    _stopwatch.reset();
    _timer?.cancel();
    setState(() => _laps.clear());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    if (d.inHours > 0) return '${d.inHours}:$min:$sec.$ms';
    return '$min:$sec.$ms';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elapsed = _stopwatch.elapsed;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Text(
            _formatDuration(elapsed),
            style: TextStyle(
              fontSize: 52, fontWeight: FontWeight.w200,
              fontFamily: 'monospace',
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CircleBtn(icon: Icons.refresh_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.3), onTap: _reset),
            const SizedBox(width: 20),
            _CircleBtn(icon: _stopwatch.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppColors.primary, size: 68, filled: true, onTap: _startStop),
            const SizedBox(width: 20),
            _CircleBtn(icon: Icons.flag_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.3), onTap: _lap),
          ],
        ),
        const SizedBox(height: 24),
        if (_laps.isNotEmpty) ...[
          Text('Laps', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ..._laps.asMap().entries.map((e) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.dividerColor)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lap ${_laps.length - e.key}', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                Text(_formatDuration(e.value), style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace')),
              ],
            ),
          )),
        ],
      ],
    );
  }
}

// ===== COUNTDOWN TAB =====
class _CountdownTab extends StatefulWidget {
  const _CountdownTab();
  @override
  State<_CountdownTab> createState() => _CountdownTabState();
}

class _CountdownTabState extends State<_CountdownTab> {
  int _hours = 0;
  int _minutes = 5;
  int _seconds = 0;
  int _totalSeconds = 300;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  bool _isStarted = false;

  late FixedExtentScrollController _hController;
  late FixedExtentScrollController _mController;
  late FixedExtentScrollController _sController;

  @override
  void initState() {
    super.initState();
    _hController = FixedExtentScrollController(initialItem: _hours);
    _mController = FixedExtentScrollController(initialItem: _minutes);
    _sController = FixedExtentScrollController(initialItem: _seconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hController.dispose();
    _mController.dispose();
    _sController.dispose();
    super.dispose();
  }

  void _start() {
    _totalSeconds = _hours * 3600 + _minutes * 60 + _seconds;
    if (_totalSeconds <= 0) return;
    _remainingSeconds = _totalSeconds;
    _isStarted = true;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          timer.cancel();
          _isRunning = false;
          _isStarted = false;
        }
      });
    });
    setState(() {});
  }

  void _pauseResume() {
    if (_isRunning) {
      _timer?.cancel();
      _isRunning = false;
    } else {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= 0) {
            timer.cancel();
            _isRunning = false;
            _isStarted = false;
          }
        });
      });
    }
    setState(() {});
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isStarted = false;
      _remainingSeconds = 0;
    });
  }

  String _formatSec(int sec) {
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    final s = sec % 60;
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _isStarted && _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 1.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 10),

        if (!_isStarted) ...[
          // Custom time picker with scroll wheels
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hours
                _ScrollPicker(
                  label: 'h',
                  controller: _hController,
                  max: 23,
                  onChanged: (v) => setState(() => _hours = v),
                  theme: theme,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(':', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                ),
                // Minutes
                _ScrollPicker(
                  label: 'm',
                  controller: _mController,
                  max: 59,
                  onChanged: (v) => setState(() => _minutes = v),
                  theme: theme,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(':', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                ),
                // Seconds
                _ScrollPicker(
                  label: 's',
                  controller: _sController,
                  max: 59,
                  onChanged: (v) => setState(() => _seconds = v),
                  theme: theme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ] else ...[
          // Running display
          Center(
            child: SizedBox(
              width: 200, height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200, height: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: theme.dividerColor.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation(_remainingSeconds <= 10 ? AppColors.expense : AppColors.primary),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    _formatSec(_remainingSeconds),
                    style: TextStyle(fontSize: _remainingSeconds >= 3600 ? 28 : 38, fontWeight: FontWeight.w200, fontFamily: 'monospace', color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isStarted) ...[
              _CircleBtn(icon: Icons.stop_rounded, color: AppColors.expense, onTap: _reset),
              const SizedBox(width: 20),
              _CircleBtn(icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppColors.primary, size: 68, filled: true, onTap: _pauseResume),
            ] else
              _CircleBtn(icon: Icons.play_arrow_rounded, color: AppColors.primary, size: 68, filled: true, onTap: _start),
          ],
        ),
      ],
    );
  }
}

// Scroll wheel picker for time
class _ScrollPicker extends StatelessWidget {
  final String label;
  final FixedExtentScrollController controller;
  final int max;
  final ValueChanged<int> onChanged;
  final ThemeData theme;

  const _ScrollPicker({required this.label, required this.controller, required this.max, required this.onChanged, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          height: 150,
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 50,
            physics: const FixedExtentScrollPhysics(),
            diameterRatio: 1.5,
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < 0 || index > max) return null;
                final isSelected = controller.hasClients && controller.selectedItem == index;
                return Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: isSelected ? 32 : 20,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w300,
                      color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.25),
                      fontFamily: 'monospace',
                    ),
                    child: Text(index.toString().padLeft(2, '0')),
                  ),
                );
              },
              childCount: max + 1,
            ),
          ),
        ),
      ],
    );
  }
}

// ===== INTERVAL TAB =====
class _IntervalTab extends StatefulWidget {
  const _IntervalTab();
  @override
  State<_IntervalTab> createState() => _IntervalTabState();
}

class _IntervalTabState extends State<_IntervalTab> {
  int _workSeconds = 25;
  int _restSeconds = 5;
  int _rounds = 4;
  int _currentRound = 0;
  int _remaining = 0;
  bool _isWork = true;
  bool _isRunning = false;
  bool _isStarted = false;
  Timer? _timer;

  void _start() {
    _currentRound = 1;
    _isWork = true;
    _remaining = _workSeconds;
    _isStarted = true;
    _isRunning = true;
    _runTimer();
    setState(() {});
  }

  void _runTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          if (_isWork) {
            if (_currentRound >= _rounds) {
              timer.cancel();
              _isRunning = false;
              _isStarted = false;
              return;
            }
            _isWork = false;
            _remaining = _restSeconds;
          } else {
            _currentRound++;
            _isWork = true;
            _remaining = _workSeconds;
          }
        }
      });
    });
  }

  void _pauseResume() {
    if (_isRunning) {
      _timer?.cancel();
      _isRunning = false;
    } else {
      _isRunning = true;
      _runTimer();
    }
    setState(() {});
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isStarted = false;
      _currentRound = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_isStarted) ...[
          const SizedBox(height: 10),
          // Phase indicator
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: (_isWork ? AppColors.primary : AppColors.income).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isWork ? '💪 WORK' : '😌 REST',
                style: TextStyle(fontWeight: FontWeight.w700, color: _isWork ? AppColors.primary : AppColors.income),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Timer display
          Center(
            child: SizedBox(
              width: 180, height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180, height: 180,
                    child: CircularProgressIndicator(
                      value: _remaining / (_isWork ? _workSeconds : _restSeconds),
                      strokeWidth: 8,
                      backgroundColor: theme.dividerColor.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation(_isWork ? AppColors.primary : AppColors.income),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(_remaining ~/ 60).toString().padLeft(2, '0')}:${(_remaining % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 38, fontWeight: FontWeight.w200, fontFamily: 'monospace', color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text('Round $_currentRound / $_rounds', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CircleBtn(icon: Icons.stop_rounded, color: AppColors.expense, onTap: _reset),
              const SizedBox(width: 20),
              _CircleBtn(icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppColors.primary, size: 68, filled: true, onTap: _pauseResume),
            ],
          ),
        ] else ...[
          // Presets
          Text('Quick Presets', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _PresetChip(label: '🏊 Swimming', onTap: () => setState(() { _workSeconds = 60; _restSeconds = 20; _rounds = 8; })),
                _PresetChip(label: '🏃 Running', onTap: () => setState(() { _workSeconds = 120; _restSeconds = 30; _rounds = 5; })),
                _PresetChip(label: '🔥 HIIT', onTap: () => setState(() { _workSeconds = 30; _restSeconds = 15; _rounds = 10; })),
                _PresetChip(label: '🧘 Yoga', onTap: () => setState(() { _workSeconds = 45; _restSeconds = 15; _rounds = 6; })),
                _PresetChip(label: '📖 Study', onTap: () => setState(() { _workSeconds = 1500; _restSeconds = 300; _rounds = 4; })),
                _PresetChip(label: '💪 Workout', onTap: () => setState(() { _workSeconds = 45; _restSeconds = 15; _rounds = 8; })),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Settings
          _IntervalSetting(
            label: 'Work Duration',
            valueText: '${_workSeconds}s',
            displayText: _formatInterval(_workSeconds),
            color: AppColors.primary,
            icon: Icons.fitness_center_rounded,
            onMinus: () { if (_workSeconds > 5) setState(() => _workSeconds -= 5); },
            onPlus: () => setState(() => _workSeconds += 5),
          ),
          _IntervalSetting(
            label: 'Rest Duration',
            valueText: '${_restSeconds}s',
            displayText: _formatInterval(_restSeconds),
            color: AppColors.income,
            icon: Icons.self_improvement_rounded,
            onMinus: () { if (_restSeconds > 5) setState(() => _restSeconds -= 5); },
            onPlus: () => setState(() => _restSeconds += 5),
          ),
          _IntervalSetting(
            label: 'Rounds',
            valueText: '$_rounds',
            displayText: '$_rounds rounds',
            color: const Color(0xFFF59E0B),
            icon: Icons.repeat_rounded,
            onMinus: () { if (_rounds > 1) setState(() => _rounds--); },
            onPlus: () => setState(() => _rounds++),
          ),
          const SizedBox(height: 8),

          // Total time info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule_rounded, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 8),
                Text(
                  'Total: ${_formatInterval((_workSeconds + _restSeconds) * _rounds)}',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: _CircleBtn(icon: Icons.play_arrow_rounded, color: AppColors.primary, size: 68, filled: true, onTap: _start),
          ),
        ],
      ],
    );
  }

  String _formatInterval(int sec) {
    if (sec >= 60) {
      final m = sec ~/ 60;
      final s = sec % 60;
      return s > 0 ? '${m}m ${s}s' : '${m}m';
    }
    return '${sec}s';
  }
}

class _IntervalSetting extends StatelessWidget {
  final String label;
  final String valueText;
  final String displayText;
  final Color color;
  final IconData icon;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _IntervalSetting({
    required this.label,
    required this.valueText,
    required this.displayText,
    required this.color,
    required this.icon,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(displayText, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
              ],
            ),
          ),
          _SmallBtn(icon: Icons.remove, onTap: onMinus),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(valueText, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
          ),
          _SmallBtn(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SmallBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

// ===== SHARED CIRCLE BUTTON =====
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool filled;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.color, this.size = 48, this.filled = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          boxShadow: filled ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
        ),
        child: Icon(icon, color: filled ? Colors.white : color, size: size * 0.38),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
      ),
    );
  }
}
