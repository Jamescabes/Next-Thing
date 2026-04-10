import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeIndicator extends StatefulWidget {
  const TimeIndicator({super.key});

  @override
  State<TimeIndicator> createState() => _TimeIndicatorState();
}

class _TimeIndicatorState extends State<TimeIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkCtrl;
  late Animation<double> _blinkAnim;

  @override
  void initState() {
    super.initState();
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _blinkAnim = Tween<double>(begin: 0.3, end: 1.0).animate(_blinkCtrl);
  }

  @override
  void dispose() {
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? Colors.white24 : Colors.black12;
    final dotColor = isDark ? Colors.white60 : Colors.black45;
    final textColor = isDark ? Colors.white54 : Colors.black38;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          FadeTransition(
            opacity: _blinkAnim,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'AHORA',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(height: 1, color: lineColor),
          ),
        ],
      ),
    );
  }
}
