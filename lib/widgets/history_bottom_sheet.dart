import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import 'event_bottom_sheet.dart';

class HistoryBottomSheet extends StatefulWidget {
  const HistoryBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const HistoryBottomSheet(),
    );
  }

  @override
  State<HistoryBottomSheet> createState() => _HistoryBottomSheetState();
}

class _HistoryBottomSheetState extends State<HistoryBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _listLimit = 30;
  DateTime _calMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subColor = isDark ? Colors.white54 : Colors.black45;
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final surfaceDim = isDark ? const Color(0xFF222222) : const Color(0xFFF5F5F5);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 12, 0),
                child: Row(
                  children: [
                    Text(
                      'Historial',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                      color: subColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceDim,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabCtrl,
                    labelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle:
                        GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
                    labelColor: textColor,
                    unselectedLabelColor: subColor,
                    indicator: BoxDecoration(
                      color: isDark ? const Color(0xFF3A3A3A) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Lista'),
                      Tab(text: 'Calendario'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Consumer<TaskProvider>(
                  builder: (context, tasks, _) {
                    final all = tasks.allTasks;
                    return TabBarView(
                      controller: _tabCtrl,
                      children: [
                        _ListView(
                          tasks: all,
                          limit: _listLimit,
                          isDark: isDark,
                          textColor: textColor,
                          subColor: subColor,
                          scrollController: scrollController,
                          onLoadMore: () =>
                              setState(() => _listLimit += 30),
                          onTap: (task) {
                            Navigator.pop(context);
                            Future.delayed(
                              const Duration(milliseconds: 200),
                              () {
                                if (context.mounted) {
                                  EventBottomSheet.show(context,
                                      existing: task);
                                }
                              },
                            );
                          },
                        ),
                        _CalendarView(
                          tasks: all,
                          month: _calMonth,
                          isDark: isDark,
                          textColor: textColor,
                          subColor: subColor,
                          onMonthChanged: (dt) =>
                              setState(() => _calMonth = dt),
                          onTaskTap: (task) {
                            Navigator.pop(context);
                            Future.delayed(
                              const Duration(milliseconds: 200),
                              () {
                                if (context.mounted) {
                                  EventBottomSheet.show(context,
                                      existing: task);
                                }
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ListView extends StatelessWidget {
  final List<TaskModel> tasks;
  final int limit;
  final bool isDark;
  final Color textColor;
  final Color subColor;
  final ScrollController scrollController;
  final VoidCallback onLoadMore;
  final ValueChanged<TaskModel> onTap;

  const _ListView({
    required this.tasks,
    required this.limit,
    required this.isDark,
    required this.textColor,
    required this.subColor,
    required this.scrollController,
    required this.onLoadMore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'No hay eventos en el historial',
          style: GoogleFonts.inter(color: subColor, fontSize: 15),
        ),
      );
    }

    final sorted = [...tasks]
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final shown = sorted.take(limit).toList();

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: shown.length + (sorted.length > limit ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i == shown.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: onLoadMore,
              child: Text(
                'Cargar más',
                style: GoogleFonts.inter(color: textColor),
              ),
            ),
          );
        }
        final task = shown[i];
        final cardColor = AppTheme.taskCardColor(task.color, isDark);
        final fg = _fg(cardColor);
        return GestureDetector(
          onTap: () => onTap(task),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: task.isCompleted ? 0.5 : 1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: fg,
                          decoration:
                              task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _fmt(task),
                        style: GoogleFonts.inter(
                            fontSize: 12, color: fg.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                if (task.isCompleted)
                  Icon(Icons.check_circle_rounded,
                      size: 18, color: fg.withValues(alpha: 0.5)),
              ],
            ),
          ),
        );
      },
    );
  }

  String _fmt(TaskModel t) {
    try {
      final dt = t.dateTime;
      return DateFormat('d MMM yyyy${t.time.isNotEmpty ? ' · HH:mm' : ''}', 'es')
          .format(dt);
    } catch (_) {
      return t.date;
    }
  }

  Color _fg(Color bg) {
    return bg.computeLuminance() > 0.4
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFF0F0F0);
  }
}

class _CalendarView extends StatelessWidget {
  final List<TaskModel> tasks;
  final DateTime month;
  final bool isDark;
  final Color textColor;
  final Color subColor;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<TaskModel> onTaskTap;

  const _CalendarView({
    required this.tasks,
    required this.month,
    required this.isDark,
    required this.textColor,
    required this.subColor,
    required this.onMonthChanged,
    required this.onTaskTap,
  });

  Map<int, List<TaskModel>> get _tasksByDay {
    final map = <int, List<TaskModel>>{};
    for (final task in tasks) {
      try {
        final dt = DateTime.parse(task.date);
        if (dt.year == month.year && dt.month == month.month) {
          map.putIfAbsent(dt.day, () => []).add(task);
        }
      } catch (_) {}
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = (firstDay.weekday % 7); // 0=Sun
    final byDay = _tasksByDay;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => onMonthChanged(
                  DateTime(month.year, month.month - 1),
                ),
                color: textColor,
              ),
              Text(
                DateFormat('MMMM yyyy', 'es').format(month),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => onMonthChanged(
                  DateTime(month.year, month.month + 1),
                ),
                color: textColor,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['D', 'L', 'M', 'X', 'J', 'V', 'S']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: subColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (ctx, i) {
              if (i < startWeekday) return const SizedBox.shrink();
              final day = i - startWeekday + 1;
              final dayTasks = byDay[day] ?? [];
              final isToday = DateTime.now().day == day &&
                  DateTime.now().month == month.month &&
                  DateTime.now().year == month.year;

              return _DayCell(
                day: day,
                tasks: dayTasks,
                isToday: isToday,
                isDark: isDark,
                textColor: textColor,
                onTaskTap: onTaskTap,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DayCell extends StatefulWidget {
  final int day;
  final List<TaskModel> tasks;
  final bool isToday;
  final bool isDark;
  final Color textColor;
  final ValueChanged<TaskModel> onTaskTap;

  const _DayCell({
    required this.day,
    required this.tasks,
    required this.isToday,
    required this.isDark,
    required this.textColor,
    required this.onTaskTap,
  });

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final shown = widget.tasks.isNotEmpty
        ? widget.tasks[_offset % widget.tasks.length]
        : null;
    final cardColor = shown != null
        ? AppTheme.taskCardColor(shown.color, isDark)
        : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5));
    final hasMore = widget.tasks.length > 1;

    return GestureDetector(
      onTap: shown != null ? () => widget.onTaskTap(shown) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isToday
              ? (isDark ? Colors.white : Colors.black)
              : cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${widget.day}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.isToday
                      ? (isDark ? Colors.black : Colors.white)
                      : widget.textColor.withValues(alpha: shown != null ? 0.9 : 0.5),
                ),
              ),
            ),
            if (hasMore)
              Positioned(
                bottom: 3,
                right: 3,
                child: GestureDetector(
                  onTap: () => setState(() => _offset++),
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
