import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import 'notification_settings_sheet.dart';

class SidePanel extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;

  const SidePanel({super.key, required this.isOpen, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isOpen ? _PanelOverlay(onClose: onClose) : const SizedBox.shrink(),
    );
  }
}

class _PanelOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const _PanelOverlay({required this.onClose});

  @override
  State<_PanelOverlay> createState() => _PanelOverlayState();
}

class _PanelOverlayState extends State<_PanelOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  Future<void> _close() async {
    await _animCtrl.reverse();
    widget.onClose();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelColor = isDark ? const Color(0xFF111111) : const Color(0xFFFDFDFD);
    final textColor = isDark ? Colors.white : Colors.black;
    final subColor = isDark ? Colors.white54 : Colors.black45;
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08);

    return Stack(
      children: [
        // Backdrop
        FadeTransition(
          opacity: _fadeAnim,
          child: GestureDetector(
            onTap: _close,
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        // Panel
        SlideTransition(
          position: _slideAnim,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.78,
              height: double.infinity,
              color: panelColor,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                _initials(auth.email ?? 'U'),
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _displayName(auth.email),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  auth.email ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: subColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: dividerColor, height: 1),
                    const SizedBox(height: 16),
                    // Theme toggle
                    _PanelItem(
                      icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      label: isDark ? 'Modo Claro' : 'Modo Oscuro',
                      textColor: textColor,
                      onTap: () {
                        theme.toggle();
                        _close();
                      },
                    ),
                    // Notifications
                    _PanelItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notificaciones',
                      textColor: textColor,
                      onTap: () {
                        _close().then((_) {
                          if (context.mounted) {
                            NotificationSettingsSheet.show(context);
                          }
                        });
                      },
                    ),
                    const Spacer(),
                    Divider(color: dividerColor, height: 1),
                    const SizedBox(height: 8),
                    // Sign out
                    _PanelItem(
                      icon: Icons.logout_rounded,
                      label: 'Cerrar sesión',
                      textColor: textColor,
                      onTap: () {
                        _close().then((_) {
                          context.read<TaskProvider>().reset();
                          context.read<ap.AuthProvider>().signOut();
                        });
                      },
                    ),
                    // Delete account
                    _PanelItem(
                      icon: Icons.delete_forever_outlined,
                      label: 'Eliminar cuenta',
                      textColor: Colors.red.shade400,
                      onTap: () => _confirmDeleteAccount(context),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Next Thing v1.0.0',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: subColor.withValues(alpha: 0.5),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Eliminar cuenta',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
            'Esto eliminará permanentemente tu cuenta y todos tus datos. ¿Continuar?',
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar',
                style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await _close();
      if (context.mounted) {
        context.read<TaskProvider>().reset();
        context.read<ap.AuthProvider>().deleteAccount();
      }
    }
  }

  String _initials(String email) {
    return email.isNotEmpty ? email[0].toUpperCase() : 'U';
  }

  String _displayName(String? email) {
    if (email == null) return 'Usuario';
    return email.split('@').first;
  }
}

class _PanelItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color textColor;
  final VoidCallback onTap;

  const _PanelItem({
    required this.icon,
    required this.label,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
