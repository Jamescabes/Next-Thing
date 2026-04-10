import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ColorPickerWidget extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const ColorPickerWidget({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppColorPresets.presets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final preset = AppColorPresets.presets[i];
          final hex = preset['light']!;
          final displayColor = AppTheme.taskCardColor(hex, isDark);
          final isSelected = selected == hex;

          return GestureDetector(
            onTap: () => onChanged(hex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: displayColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black)
                      : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
