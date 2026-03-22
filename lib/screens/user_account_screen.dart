import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';

class UserAccountScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final int? previousTabIndex;
  const UserAccountScreen({
    super.key,
    this.scrollController,
    this.previousTabIndex,
  });

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen>
    with TickerProviderStateMixin {
  late AnimationController _blob1Controller;
  late AnimationController _blob2Controller;
  late Animation<double> _blob1Anim;
  late Animation<double> _blob2Anim;
  late AnimationController _appearController;
  late Animation<double> _appearAnim;

  // Notification toggles
  bool _notifGastos = true;
  bool _notifMetas = true;
  bool _notifResumen = false;
  bool _notifPromociones = false;

  @override
  void initState() {
    super.initState();
    _blob1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);
    _blob2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
    _blob1Anim = CurvedAnimation(
      parent: _blob1Controller,
      curve: Curves.easeInOut,
    );
    _blob2Anim = CurvedAnimation(
      parent: _blob2Controller,
      curve: Curves.easeInOut,
    );

    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _appearAnim = CurvedAnimation(
      parent: _appearController,
      curve: const Cubic(0.34, 1.56, 0.64, 1.0),
    );
    _appearController.forward();
  }

  @override
  void dispose() {
    _blob1Controller.dispose();
    _blob2Controller.dispose();
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        RepaintBoundary(
          child: AnimatedBlobs(blob1Anim: _blob1Anim, blob2Anim: _blob2Anim),
        ),
        Positioned.fill(
          child: SingleChildScrollView(
            controller: widget.scrollController ?? ScrollController(),
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: topPadding + 76, bottom: 80),
            child: FadeTransition(
              opacity: _appearAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(_appearAnim),
                child: Column(
                  children: [
                    // ── Avatar header ─────────────────────────────────
                    _AvatarHeader(),
                    const SizedBox(height: 28),

                    // ── Suscripción ───────────────────────────────────
                    _SubscriptionCard(),
                    const SizedBox(height: 28),

                    // ── Configuración general ─────────────────────────
                    _SettingsSection(
                      title: 'CONFIGURACIÓN',
                      rows: [
                        _SettingsRow(
                          icon: CupertinoIcons.globe,
                          color: AppColors.systemBlue,
                          label: 'Moneda',
                          trailing: const _TrailingValue('MXN — Peso'),
                          onTap: () {},
                        ),
                        _SettingsRow(
                          icon: CupertinoIcons.calendar,
                          color: AppColors.systemOrange,
                          label: 'Inicio de mes',
                          trailing: const _TrailingValue('Día 1'),
                          onTap: () {},
                        ),
                        _SettingsRow(
                          icon: CupertinoIcons.cloud_download,
                          color: AppColors.systemGreen,
                          label: 'Exportar datos',
                          trailing: const _TrailingChevron(),
                          onTap: () {},
                        ),
                        _SettingsRow(
                          icon: CupertinoIcons.trash,
                          color: AppColors.systemRed,
                          label: 'Eliminar cuenta',
                          trailing: const _TrailingChevron(),
                          isDestructive: true,
                          onTap: () {},
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Seguridad ─────────────────────────────────────
                    _SettingsSection(
                      title: 'SEGURIDAD',
                      rows: [
                        _SettingsRow(
                          icon: CupertinoIcons.hand_raised_fill,
                          color: AppColors.systemBlue,
                          label: 'Face ID / Touch ID',
                          trailing: const _TrailingChevron(),
                          onTap: () {},
                        ),
                        _SettingsRow(
                          icon: CupertinoIcons.lock_rotation,
                          color: AppColors.systemPurple,
                          label: 'Cambiar contraseña',
                          trailing: const _TrailingChevron(),
                          onTap: () {},
                        ),
                        _SettingsRow(
                          icon: CupertinoIcons.device_phone_portrait,
                          color: AppColors.systemIndigo,
                          label: 'Dispositivos activos',
                          trailing: const _TrailingValue('1 dispositivo'),
                          onTap: () {},
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Notificaciones ────────────────────────────────
                    _SettingsSection(
                      title: 'NOTIFICACIONES',
                      rows: [
                        _ToggleRow(
                          icon: CupertinoIcons.bell_fill,
                          color: AppColors.systemRed,
                          label: 'Alertas de gastos',
                          subtitle: 'Cuando superes tu presupuesto',
                          value: _notifGastos,
                          onChanged: (v) => setState(() => _notifGastos = v),
                        ),
                        _ToggleRow(
                          icon: CupertinoIcons.flag_fill,
                          color: AppColors.systemGreen,
                          label: 'Progreso de metas',
                          subtitle: 'Hitos y recordatorios',
                          value: _notifMetas,
                          onChanged: (v) => setState(() => _notifMetas = v),
                        ),
                        _ToggleRow(
                          icon: CupertinoIcons.chart_bar_fill,
                          color: AppColors.systemBlue,
                          label: 'Resumen semanal',
                          subtitle: 'Cada lunes por la mañana',
                          value: _notifResumen,
                          onChanged: (v) => setState(() => _notifResumen = v),
                        ),
                        _ToggleRow(
                          icon: CupertinoIcons.tag_fill,
                          color: AppColors.systemOrange,
                          label: 'Promociones',
                          subtitle: 'Ofertas y novedades de Finanzas',
                          value: _notifPromociones,
                          onChanged: (v) =>
                              setState(() => _notifPromociones = v),
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Cerrar sesión ─────────────────────────────────
                    _SignOutButton(),
                    const SizedBox(height: 12),

                    // ── Version ───────────────────────────────────────
                    const Text(
                      'Finanzas v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.tertiaryLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
