import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  late Animation<double> _elevationAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _elevationAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  Color _cardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppTheme.taskCardColor(widget.task.color, isDark);
  }

  Color _textColor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.4 ? const Color(0xFF1A1A1A) : const Color(0xFFF0F0F0);
  }

  String _formatDateTime() {
    if (widget.task.time.isEmpty) {
      try {
        final dt = DateTime.parse(widget.task.date);
        return DateFormat('d MMM', 'es').format(dt);
      } catch (_) {
        return widget.task.date;
      }
    }
    try {
      final dt = widget.task.dateTime;
      return DateFormat('d MMM · HH:mm', 'es').format(dt);
    } catch (_) {
      return '${widget.task.date} · ${widget.task.time}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _cardColor(context);
    final textColor = _textColor(cardColor);
    final isCompleted = widget.task.isCompleted;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);

    return AnimatedBuilder(
      animation: _elevationAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _pressed ? 0.98 : 1.0,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _pressed = true);
          _hoverCtrl.forward();
        },
        onTapUp: (_) {
          setState(() => _pressed = false);
          _hoverCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () {
          setState(() => _pressed = false);
          _hoverCtrl.reverse();
        },
        child: AnimatedOpacity(
          opacity: isCompleted ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 52, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: textColor.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: textColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: textColor.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      if (widget.task.location.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.place_outlined,
                              size: 13,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.task.location,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: textColor.withValues(alpha: 0.6),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (widget.task.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.task.description,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: textColor.withValues(alpha: 0.55),
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: GestureDetector(
                    onTap: widget.onToggleComplete,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? textColor.withValues(alpha: 0.8)
                            : Colors.transparent,
                        border: Border.all(
                          color: textColor.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isCompleted
                          ? Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: cardColor,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
