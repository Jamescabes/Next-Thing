import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/event_bottom_sheet.dart';
import '../../widgets/history_bottom_sheet.dart';
import '../../widgets/side_panel.dart';
import '../../widgets/task_card.dart';
import '../../widgets/time_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _panelOpen = false;
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  now: _now,
                  isDark: isDark,
                  textColor: textColor,
                  onSettingsTap: () => setState(() => _panelOpen = true),
                  onHistoryTap: () => HistoryBottomSheet.show(context),
                ),
                Expanded(child: _Timeline(now: _now)),
              ],
            ),
          ),
          SidePanel(
            isOpen: _panelOpen,
            onClose: () => setState(() => _panelOpen = false),
          ),
        ],
      ),
      floatingActionButton: _FAB(
        onTap: () => EventBottomSheet.show(context),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final DateTime now;
  final bool isDark;
  final Color textColor;
  final VoidCallback onSettingsTap;
  final VoidCallback onHistoryTap;

  const _TopBar({
    required this.now,
    required this.isDark,
    required this.textColor,
    required this.onSettingsTap,
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EEEE', 'es').format(now).toUpperCase();
    final dateStr = DateFormat('d MMM', 'es').format(now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayName,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                dateStr,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black45,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const Spacer(),
          _IconBtn(
            icon: Icons.menu_rounded,
            isDark: isDark,
            onTap: onSettingsTap,
          ),
          const SizedBox(width: 8),
          _IconBtn(
            icon: Icons.history_rounded,
            isDark: isDark,
            onTap: onHistoryTap,
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final DateTime now;

  const _Timeline({required this.now});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? Colors.white38 : Colors.black26;

    if (tasks.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final future = tasks.futureTasks;
    final past = tasks.pastTasks;
    final hasMorePast = tasks.hasMorePast;

    if (future.isEmpty && past.isEmpty) {
      return _EmptyState(isDark: isDark);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        // Future tasks
        ...future.map(
          (task) => AnimatedTaskCard(
            key: ValueKey(task.id),
            task: task,
            onTap: () => EventBottomSheet.show(context, existing: task),
            onToggle: () =>
                context.read<TaskProvider>().toggleComplete(task),
          ),
        ),
        // NOW separator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const TimeIndicator(),
        ),
        // Past tasks
        ...past.map(
          (task) => AnimatedTaskCard(
            key: ValueKey(task.id),
            task: task,
            onTap: () => EventBottomSheet.show(context, existing: task),
            onToggle: () =>
                context.read<TaskProvider>().toggleComplete(task),
          ),
        ),
        // Load more
        if (hasMorePast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextButton(
              onPressed: () => context.read<TaskProvider>().loadMorePast(),
              child: Text(
                'Cargar más',
                style: GoogleFonts.inter(
                  color: subColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class AnimatedTaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const AnimatedTaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
  });

  @override
  State<AnimatedTaskCard> createState() => _AnimatedTaskCardState();
}

class _AnimatedTaskCardState extends State<AnimatedTaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: FadeTransition(
        opacity: _opacityAnim,
        child: TaskCard(
          task: widget.task,
          onTap: widget.onTap,
          onToggleComplete: widget.onToggle,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;

  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '✓',
            style: GoogleFonts.inter(
              fontSize: 48,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Todo está en orden',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca + para agregar un evento',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}

class _FAB extends StatefulWidget {
  final VoidCallback onTap;

  const _FAB({required this.onTap});

  @override
  State<_FAB> createState() => _FABState();
}

class _FABState extends State<_FAB> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.elasticOut,
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.animateTo(0.85,
            duration: const Duration(milliseconds: 100)),
        onTapUp: (_) {
          _ctrl.animateTo(1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut);
          widget.onTap();
        },
        onTapCancel: () => _ctrl.animateTo(1.0,
            duration: const Duration(milliseconds: 200)),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isDark ? Colors.white : Colors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.add_rounded,
            color: isDark ? Colors.black : Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
