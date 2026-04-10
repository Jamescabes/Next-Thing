import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import 'color_picker_widget.dart';
import 'date_time_picker_widget.dart';

class EventBottomSheet extends StatefulWidget {
  final TaskModel? existing;

  const EventBottomSheet({super.key, this.existing});

  static Future<void> show(BuildContext context, {TaskModel? existing}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => EventBottomSheet(existing: existing),
    );
  }

  @override
  State<EventBottomSheet> createState() => _EventBottomSheetState();
}

class _EventBottomSheetState extends State<EventBottomSheet>
    with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;

  String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _time = '';
  String _color = '#ffffff';
  List<NotificationOffset> _notifications = [];
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    if (widget.existing != null) {
      final t = widget.existing!;
      _titleCtrl.text = t.title;
      _locationCtrl.text = t.location;
      _notesCtrl.text = t.description;
      _date = t.date;
      _time = t.time;
      _color = t.color;
      _notifications = List.from(t.notifications);
    } else {
      _color = AppColorPresets.randomPool[
          Random().nextInt(AppColorPresets.randomPool.length)];
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final tasks = context.read<TaskProvider>();
    final task = TaskModel(
      id: widget.existing?.id,
      title: _titleCtrl.text.trim(),
      description: _notesCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      date: _date,
      time: _time,
      color: _color,
      isCompleted: widget.existing?.isCompleted ?? false,
      notifications: _notifications,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      await tasks.updateTask(task);
    } else {
      await tasks.addTask(task);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (widget.existing?.id == null) return;
    final confirmed = await _confirmDelete();
    if (!confirmed) return;
    await context.read<TaskProvider>().deleteTask(widget.existing!.id!);
    if (mounted) Navigator.pop(context);
  }

  Future<bool> _confirmDelete() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text('Eliminar evento',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            content: Text('¿Deseas eliminar este evento?',
                style: GoogleFonts.inter()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Eliminar',
                  style: GoogleFonts.inter(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _addNotification() {
    showDialog(
      context: context,
      builder: (ctx) => _NotificationDialog(
        onAdd: (offset) {
          setState(() => _notifications.add(offset));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subColor = isDark ? Colors.white54 : Colors.black45;
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final dividerColor = isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08);

    return SlideTransition(
      position: _slideAnim,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    _isEditing ? 'Editar evento' : 'Nuevo evento',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  if (_isEditing)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: Colors.red.shade400,
                      onPressed: _delete,
                    ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    color: subColor,
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleCtrl,
                        style: GoogleFonts.inter(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'El título es requerido';
                          }
                          return null;
                        },
                        autofocus: !_isEditing,
                      ),
                      const SizedBox(height: 16),
                      _SectionLabel(
                        label: 'FECHA Y HORA',
                        subColor: subColor,
                      ),
                      const SizedBox(height: 10),
                      DateTimePickerWidget(
                        date: _date,
                        time: _time,
                        onDateChanged: (d) => setState(() => _date = d),
                        onTimeChanged: (t) => setState(() => _time = t),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: dividerColor),
                      const SizedBox(height: 16),
                      _SectionLabel(label: 'COLOR', subColor: subColor),
                      const SizedBox(height: 10),
                      ColorPickerWidget(
                        selected: _color,
                        onChanged: (c) => setState(() => _color = c),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: dividerColor),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationCtrl,
                        style: GoogleFonts.inter(color: textColor),
                        decoration: const InputDecoration(
                          labelText: 'Ubicación (opcional)',
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesCtrl,
                        style: GoogleFonts.inter(color: textColor),
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notas (opcional)',
                          prefixIcon: Icon(Icons.notes_rounded),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: dividerColor),
                      const SizedBox(height: 12),
                      _SectionLabel(
                          label: 'RECORDATORIOS', subColor: subColor),
                      const SizedBox(height: 10),
                      ..._notifications.map(
                        (n) => _NotificationChip(
                          offset: n,
                          isDark: isDark,
                          textColor: textColor,
                          onRemove: () =>
                              setState(() => _notifications.remove(n)),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addNotification,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(
                          'Agregar recordatorio',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white54),
                          ),
                        )
                      : Text(_isEditing ? 'Guardar cambios' : 'Crear evento'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color subColor;

  const _SectionLabel({required this.label, required this.subColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: subColor,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _NotificationChip extends StatelessWidget {
  final NotificationOffset offset;
  final bool isDark;
  final Color textColor;
  final VoidCallback onRemove;

  const _NotificationChip({
    required this.offset,
    required this.isDark,
    required this.textColor,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_outlined, size: 16),
          const SizedBox(width: 8),
          Text(
            offset.label,
            style: GoogleFonts.inter(fontSize: 14, color: textColor),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded,
                size: 16, color: textColor.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}

class _NotificationDialog extends StatefulWidget {
  final ValueChanged<NotificationOffset> onAdd;

  const _NotificationDialog({required this.onAdd});

  @override
  State<_NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<_NotificationDialog> {
  int _amount = 30;
  String _unit = 'minutes';

  static const _units = [
    {'value': 'minutes', 'label': 'Minutos'},
    {'value': 'hours', 'label': 'Horas'},
    {'value': 'days', 'label': 'Días'},
    {'value': 'weeks', 'label': 'Semanas'},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Agregar recordatorio',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _amount.toString(),
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: 'Cantidad'),
                  onChanged: (v) =>
                      setState(() => _amount = int.tryParse(v) ?? 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _unit,
                  items: _units
                      .map((u) => DropdownMenuItem(
                            value: u['value'],
                            child: Text(u['label']!,
                                style: GoogleFonts.inter(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _unit = v!),
                  decoration: InputDecoration(labelText: 'Unidad'),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onAdd(NotificationOffset(
              id: 'n${DateTime.now().millisecondsSinceEpoch}',
              amount: _amount,
              unit: _unit,
            ));
            Navigator.pop(context);
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
