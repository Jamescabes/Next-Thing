import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DateTimePickerWidget extends StatefulWidget {
  final String date; // YYYY-MM-DD
  final String time; // HH:MM or empty
  final ValueChanged<String> onDateChanged;
  final ValueChanged<String> onTimeChanged;

  const DateTimePickerWidget({
    super.key,
    required this.date,
    required this.time,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  @override
  State<DateTimePickerWidget> createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  late int _hour;
  late int _minute;
  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minuteCtrl;
  bool _hasTime = false;

  static const _hourItemH = 52.0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _hasTime = widget.time.isNotEmpty;
    if (_hasTime) {
      final parts = widget.time.split(':');
      _hour = int.tryParse(parts[0]) ?? 0;
      _minute = int.tryParse(parts[1]) ?? 0;
    } else {
      final now = DateTime.now();
      _hour = now.hour;
      _minute = (now.minute ~/ 5) * 5;
    }
    _hourCtrl = FixedExtentScrollController(initialItem: _hour);
    _minuteCtrl = FixedExtentScrollController(initialItem: _minute ~/ 5);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  String get _selectedDate => widget.date;

  void _selectDate(DateTime dt) {
    widget.onDateChanged(DateFormat('yyyy-MM-dd').format(dt));
  }

  void _emitTime() {
    final t = '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';
    widget.onTimeChanged(t);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subColor = isDark ? Colors.white54 : Colors.black45;
    final surfaceColor = isDark ? const Color(0xFF222222) : const Color(0xFFF5F5F5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
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
              Tab(text: 'Fecha'),
              Tab(text: 'Hora'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: TabBarView(
            controller: _tabCtrl,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _DatePicker(
                selected: _selectedDate,
                onSelect: _selectDate,
                isDark: isDark,
                textColor: textColor,
                subColor: subColor,
              ),
              _TimePicker(
                hour: _hour,
                minute: _minute,
                hasTime: _hasTime,
                hourCtrl: _hourCtrl,
                minuteCtrl: _minuteCtrl,
                isDark: isDark,
                textColor: textColor,
                subColor: subColor,
                itemHeight: _hourItemH,
                onHourChanged: (h) {
                  setState(() => _hour = h);
                  if (_hasTime) _emitTime();
                },
                onMinuteChanged: (m) {
                  setState(() => _minute = m * 5);
                  if (_hasTime) _emitTime();
                },
                onToggleTime: (val) {
                  setState(() => _hasTime = val);
                  if (val) {
                    _emitTime();
                  } else {
                    widget.onTimeChanged('');
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DatePicker extends StatelessWidget {
  final String selected;
  final ValueChanged<DateTime> onSelect;
  final bool isDark;
  final Color textColor;
  final Color subColor;

  const _DatePicker({
    required this.selected,
    required this.onSelect,
    required this.isDark,
    required this.textColor,
    required this.subColor,
  });

  DateTime get _selected {
    try {
      return DateTime.parse(selected);
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfter = today.add(const Duration(days: 2));
    final chipBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0);
    final selectedBg = isDark ? Colors.white : Colors.black;
    final selectedFg = isDark ? Colors.black : Colors.white;

    String fmt(DateTime dt) => DateFormat('d MMM', 'es').format(dt);

    bool isSelected(DateTime dt) {
      try {
        final s = DateTime.parse(selected);
        return s.year == dt.year && s.month == dt.month && s.day == dt.day;
      } catch (_) {
        return false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _QuickChip(
              label: 'Hoy',
              sublabel: fmt(today),
              isSelected: isSelected(today),
              bg: chipBg,
              selectedBg: selectedBg,
              selectedFg: selectedFg,
              textColor: textColor,
              subColor: subColor,
              onTap: () => onSelect(today),
            ),
            const SizedBox(width: 10),
            _QuickChip(
              label: 'Mañana',
              sublabel: fmt(tomorrow),
              isSelected: isSelected(tomorrow),
              bg: chipBg,
              selectedBg: selectedBg,
              selectedFg: selectedFg,
              textColor: textColor,
              subColor: subColor,
              onTap: () => onSelect(tomorrow),
            ),
            const SizedBox(width: 10),
            _QuickChip(
              label: 'Pasado',
              sublabel: fmt(dayAfter),
              isSelected: isSelected(dayAfter),
              bg: chipBg,
              selectedBg: selectedBg,
              selectedFg: selectedFg,
              textColor: textColor,
              subColor: subColor,
              onTap: () => onSelect(dayAfter),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            final dt = await showDatePicker(
              context: context,
              initialDate: _selected,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              locale: const Locale('es'),
            );
            if (dt != null) onSelect(dt);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF222222) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16, color: subColor),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, d MMMM yyyy', 'es').format(_selected),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool isSelected;
  final Color bg;
  final Color selectedBg;
  final Color selectedFg;
  final Color textColor;
  final Color subColor;
  final VoidCallback onTap;

  const _QuickChip({
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.bg,
    required this.selectedBg,
    required this.selectedFg,
    required this.textColor,
    required this.subColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? selectedFg : textColor,
              ),
            ),
            Text(
              sublabel,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isSelected ? selectedFg.withValues(alpha: 0.7) : subColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final int hour;
  final int minute;
  final bool hasTime;
  final FixedExtentScrollController hourCtrl;
  final FixedExtentScrollController minuteCtrl;
  final bool isDark;
  final Color textColor;
  final Color subColor;
  final double itemHeight;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;
  final ValueChanged<bool> onToggleTime;

  const _TimePicker({
    required this.hour,
    required this.minute,
    required this.hasTime,
    required this.hourCtrl,
    required this.minuteCtrl,
    required this.isDark,
    required this.textColor,
    required this.subColor,
    required this.itemHeight,
    required this.onHourChanged,
    required this.onMinuteChanged,
    required this.onToggleTime,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceDim = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hora específica',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Switch(
              value: hasTime,
              onChanged: onToggleTime,
              activeThumbColor: isDark ? Colors.white : Colors.black,
              trackColor: WidgetStateProperty.all(
                isDark ? Colors.white24 : Colors.black12,
              ),
            ),
          ],
        ),
        if (hasTime) ...[
          const SizedBox(height: 8),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: itemHeight,
                  decoration: BoxDecoration(
                    color: surfaceDim,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      child: ListWheelScrollView.useDelegate(
                        controller: hourCtrl,
                        itemExtent: itemHeight,
                        onSelectedItemChanged: onHourChanged,
                        physics: const FixedExtentScrollPhysics(),
                        perspective: 0.003,
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 24,
                          builder: (ctx, i) => Center(
                            child: Text(
                              i.toString().padLeft(2, '0'),
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      ':',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: ListWheelScrollView.useDelegate(
                        controller: minuteCtrl,
                        itemExtent: itemHeight,
                        onSelectedItemChanged: onMinuteChanged,
                        physics: const FixedExtentScrollPhysics(),
                        perspective: 0.003,
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 12,
                          builder: (ctx, i) => Center(
                            child: Text(
                              (i * 5).toString().padLeft(2, '0'),
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          const Spacer(),
          Text(
            'Evento de día completo',
            style: GoogleFonts.inter(fontSize: 14, color: subColor),
          ),
          const Spacer(),
        ],
      ],
    );
  }
}
