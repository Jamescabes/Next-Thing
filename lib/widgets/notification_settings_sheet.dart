import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/notification_provider.dart';

class NotificationSettingsSheet extends StatelessWidget {
  const NotificationSettingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const NotificationSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notif = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subColor = isDark ? Colors.white54 : Colors.black45;
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
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
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Text(
                      'Notificaciones',
                      style: GoogleFonts.inter(
                        fontSize: 20,
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
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    _SectionRow(
                      title: 'Activar notificaciones',
                      subtitle: notif.enabled
                          ? 'Recibirás recordatorios de eventos'
                          : 'Las notificaciones están desactivadas',
                      isDark: isDark,
                      textColor: textColor,
                      subColor: subColor,
                      trailing: Switch(
                        value: notif.enabled,
                        onChanged: (_) => notif.toggleEnabled(),
                        activeThumbColor: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    if (notif.enabled) ...[
                      const SizedBox(height: 24),
                      Text(
                        'TIPOS',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: subColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SectionRow(
                        title: 'Próximos eventos',
                        subtitle: 'Recordatorios antes de cada evento',
                        isDark: isDark,
                        textColor: textColor,
                        subColor: subColor,
                        trailing: Switch(
                          value: notif.upcomingEvents,
                          onChanged: notif.setUpcomingEvents,
                          activeThumbColor: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'RECORDATORIOS POR DEFECTO',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: subColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _defaultPresets.map((preset) {
                          final isActive = notif.defaultOffsets
                              .any((o) => o.id == preset['id']);
                          return GestureDetector(
                            onTap: () {
                              if (isActive) {
                                notif.removeDefaultOffset(preset['id']!);
                              } else {
                                notif.addDefaultOffset(
                                  NotificationOffset(
                                    id: preset['id']!,
                                    amount: int.parse(preset['amount']!),
                                    unit: preset['unit']!,
                                  ),
                                );
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? (isDark ? Colors.white : Colors.black)
                                    : (isDark
                                        ? const Color(0xFF2A2A2A)
                                        : const Color(0xFFF0F0F0)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                preset['label']!,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isActive
                                      ? (isDark ? Colors.black : Colors.white)
                                      : textColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static const _defaultPresets = [
    {'id': 'p15m', 'label': '15 min', 'amount': '15', 'unit': 'minutes'},
    {'id': 'p30m', 'label': '30 min', 'amount': '30', 'unit': 'minutes'},
    {'id': 'p1h', 'label': '1 hora', 'amount': '1', 'unit': 'hours'},
    {'id': 'p2h', 'label': '2 horas', 'amount': '2', 'unit': 'hours'},
    {'id': 'p1d', 'label': '1 día', 'amount': '1', 'unit': 'days'},
    {'id': 'p1w', 'label': '1 semana', 'amount': '1', 'unit': 'weeks'},
  ];
}

class _SectionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;
  final Color textColor;
  final Color subColor;
  final Widget trailing;

  const _SectionRow({
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.textColor,
    required this.subColor,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 12, color: subColor),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
