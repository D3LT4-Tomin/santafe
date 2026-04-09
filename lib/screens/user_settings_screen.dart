import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../providers/subscription_provider.dart';
import 'subscription_screen.dart';

class UserSettingsScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const UserSettingsScreen({super.key, this.scrollController});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _blob1Controller;
  late AnimationController _blob2Controller;
  late Animation<double> _blob1Anim;
  late Animation<double> _blob2Anim;
  late AnimationController _appearController;
  late Animation<double> _appearAnim;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubscriptionProvider>(context, listen: false).loadPlan();
    });
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

        // Botón de regreso grande y visible
        Positioned(
          top: topPadding + 8,
          left: 16,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: CupertinoColors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.chevron_left,
                size: 24,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: SingleChildScrollView(
            controller: widget.scrollController ?? ScrollController(),
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: topPadding + 70, bottom: 80),
            child: FadeTransition(
              opacity: _appearAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(_appearAnim),
                child: Column(
                  children: [
                    Consumer<SubscriptionProvider>(
                      builder: (context, subscriptionProvider, child) {
                        return _SubscriptionCard(
                          isPremium: subscriptionProvider.isPremium,
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                    const SubscriptionScreen(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 28),

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
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

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

                    _SettingsSection(
                      title: 'ZONA PELIGRO',
                      rows: [
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

                    const _SignOutButton(),
                    const SizedBox(height: 12),

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

class _SubscriptionCard extends StatelessWidget {
  final bool isPremium;
  final VoidCallback onTap;

  const _SubscriptionCard({required this.isPremium, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPremium
                  ? [CupertinoColors.systemPurple, CupertinoColors.systemIndigo]
                  : [CupertinoColors.systemGrey, CupertinoColors.systemGrey2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color:
                    (isPremium
                            ? CupertinoColors.systemPurple
                            : CupertinoColors.systemGrey)
                        .withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPremium
                            ? CupertinoIcons.star_fill
                            : CupertinoIcons.star,
                        color: CupertinoColors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isPremium ? 'Plan Premium' : 'Plan Básico',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.white,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isPremium
                    ? 'Acceso completo a todas las funciones'
                    : 'Funciones básicas disponibles',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.white.withValues(alpha: 0.9),
                ),
              ),
              if (!isPremium) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Mejorar a Premium',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _SettingsSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: AppColors.secondaryLabel,
                height: 1.33,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white05,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.white07),
            ),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }
}

class _RowSeparator extends StatelessWidget {
  const _RowSeparator();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 56),
      child: ColoredBox(
        color: AppColors.separator,
        child: SizedBox(height: 0.5, width: double.infinity),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isLast;

  const _SettingsRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.trailing,
    required this.onTap,
    this.isDestructive = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? AppColors.systemRed.withValues(alpha: 0.12)
                        : color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: isDestructive ? AppColors.systemRed : color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDestructive
                          ? AppColors.systemRed
                          : AppColors.label,
                      height: 1.33,
                    ),
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
        if (!isLast) const _RowSeparator(),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ToggleRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.label,
                        height: 1.33,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryLabel,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CupertinoSwitch(
                value: value,
                activeTrackColor: AppColors.systemBlue,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  onChanged(v);
                },
              ),
            ],
          ),
        ),
        if (!isLast) const _RowSeparator(),
      ],
    );
  }
}

class _TrailingChevron extends StatelessWidget {
  const _TrailingChevron();
  @override
  Widget build(BuildContext context) {
    return const Icon(
      CupertinoIcons.chevron_right,
      size: 14,
      color: AppColors.tertiaryLabel,
    );
  }
}

class _TrailingValue extends StatelessWidget {
  final String value;
  const _TrailingValue(this.value);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: AppColors.secondaryLabel),
        ),
        const SizedBox(width: 4),
        const Icon(
          CupertinoIcons.chevron_right,
          size: 14,
          color: AppColors.tertiaryLabel,
        ),
      ],
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () async {
          HapticFeedback.mediumImpact();
          final authProvider = context.read<AuthProvider>();
          final dataProvider = context.read<DataProvider>();
          dataProvider.clearData();
          await authProvider.signOut();
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.systemRed.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.systemRed.withValues(alpha: 0.18),
            ),
          ),
          child: const SizedBox(
            width: double.infinity,
            height: 50,
            child: Center(
              child: Text(
                'Cerrar sesión',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.systemRed,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
