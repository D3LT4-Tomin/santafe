import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/navigation_widgets.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubscriptionProvider>(context, listen: false).loadPlan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.systemBackground.withValues(alpha: 0.8),
        border: null,
        leading: const BackButton(),
        middle: const Text(
          'Planes',
          style: TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: Consumer<SubscriptionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentPlanCard(context, provider),
                  const SizedBox(height: 32),
                  _buildPlanOption(
                    context,
                    provider,
                    plan: SubscriptionPlan.free,
                    title: 'Plan Básico',
                    subtitle: 'Para comenzar',
                    price: 'Gratis',
                    features: const [
                      'Hasta 3 cuentas',
                      'Funciones estándar',
                      'Soporte por email',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPlanOption(
                    context,
                    provider,
                    plan: SubscriptionPlan.premium,
                    title: 'Plan Premium',
                    subtitle: 'Mejor opción',
                    price: '\$9.99/mes',
                    features: const [
                      'Cuentas ilimitadas',
                      'Todas las funciones',
                      'Soporte prioritario',
                      'Sin límites de uso',
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildInfoCard(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard(
    BuildContext context,
    SubscriptionProvider provider,
  ) {
    final isPremium = provider.isPremium;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium
              ? [CupertinoColors.systemPurple, CupertinoColors.systemIndigo]
              : [CupertinoColors.systemGrey, CupertinoColors.systemGrey2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                (isPremium
                        ? CupertinoColors.systemPurple
                        : CupertinoColors.systemGrey)
                    .withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
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
                    isPremium ? CupertinoIcons.star_fill : CupertinoIcons.star,
                    color: CupertinoColors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isPremium ? 'Plan Premium' : 'Plan Básico',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPremium ? 'Activo' : 'Actual',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isPremium
                ? 'Tienes acceso completo a todas las funciones premium'
                : 'Acceso a funciones básicas para comenzar',
            style: TextStyle(
              color: CupertinoColors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
          if (isPremium) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: CupertinoColors.white.withValues(alpha: 0.9),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Renovación automática el 1 de cada mes',
                  style: TextStyle(
                    color: CupertinoColors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanOption(
    BuildContext context,
    SubscriptionProvider provider, {
    required SubscriptionPlan plan,
    required String title,
    required String subtitle,
    required String price,
    required List<String> features,
  }) {
    final isSelected = provider.currentPlan == plan;
    final isPremium = plan == SubscriptionPlan.premium;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _handlePlanSelection(context, provider, plan);
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected
              ? (isPremium
                    ? CupertinoColors.systemPurple.withValues(alpha: 0.1)
                    : CupertinoColors.systemBlue.withValues(alpha: 0.1))
              : AppColors.white05,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isPremium
                      ? CupertinoColors.systemPurple
                      : CupertinoColors.systemBlue)
                : AppColors.white07,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? (isPremium
                                    ? CupertinoColors.systemPurple
                                    : CupertinoColors.systemBlue)
                              : CupertinoColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          (isPremium
                                  ? CupertinoColors.systemPurple
                                  : CupertinoColors.systemBlue)
                              .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: isPremium
                          ? CupertinoColors.systemPurple
                          : CupertinoColors.systemBlue,
                      size: 24,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              price,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (isPremium
                          ? CupertinoColors.systemPurple
                          : CupertinoColors.systemBlue)
                    : CupertinoColors.white,
              ),
            ),
            const SizedBox(height: 20),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGreen.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        CupertinoIcons.checkmark,
                        size: 14,
                        color: CupertinoColors.systemGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          fontSize: 15,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: isSelected
                    ? CupertinoColors.systemGrey
                    : (isPremium
                          ? CupertinoColors.systemPurple
                          : CupertinoColors.systemBlue),
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _handlePlanSelection(context, provider, plan);
                },
                child: Text(
                  isSelected
                      ? 'Plan Actual'
                      : (isPremium ? 'Mejorar' : 'Seleccionar'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white05,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white07),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                CupertinoIcons.info_circle_fill,
                color: CupertinoColors.systemBlue,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Información',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Puedes cambiar de plan en cualquier momento\n'
            '• Los cambios se aplican inmediatamente\n'
            '• Los cobros se hacen el primer día de cada mes\n'
            '• Cancela cuando quieras sin penalizaciones',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.white.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  void _handlePlanSelection(
    BuildContext context,
    SubscriptionProvider provider,
    SubscriptionPlan plan,
  ) {
    if (provider.currentPlan == plan) return;

    if (plan == SubscriptionPlan.premium) {
      _showUpgradeDialog(context, provider);
    } else {
      _showDowngradeDialog(context, provider);
    }
  }

  void _showUpgradeDialog(BuildContext context, SubscriptionProvider provider) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Mejorar a Premium'),
        content: const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            '¿Deseas mejorar tu plan a Premium?\n\n'
            '• Acceso a todas las funciones\n'
            '• Cuentas ilimitadas\n'
            '• Soporte prioritario\n\n'
            'Se aplicará un cargo de \$9.99/mes',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              _processUpgrade(context, provider);
            },
            child: const Text('Mejorar'),
          ),
        ],
      ),
    );
  }

  void _showDowngradeDialog(
    BuildContext context,
    SubscriptionProvider provider,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Cambiar a Plan Básico'),
        content: const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            '¿Deseas cambiar tu plan a Básico?\n\n'
            '• Acceso a funciones limitadas\n'
            '• Máximo 3 cuentas\n'
            '• Podrás seguir usando las funciones Premium hasta el final del período de facturación',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _processDowngrade(context, provider);
            },
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  void _processUpgrade(
    BuildContext context,
    SubscriptionProvider provider,
  ) async {
    final success = await provider.updatePlan(SubscriptionPlan.premium);

    if (!mounted) return;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(success ? '¡Éxito!' : 'Error'),
        content: Text(
          success
              ? '¡Bienvenido a Premium!\n\nTus cambios se han guardado correctamente.'
              : 'No se pudo actualizar el plan. Intenta de nuevo.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _processDowngrade(
    BuildContext context,
    SubscriptionProvider provider,
  ) async {
    final success = await provider.updatePlan(SubscriptionPlan.free);

    if (!mounted) return;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(success ? '¡Listo!' : 'Error'),
        content: Text(
          success
              ? 'Has cambiado al Plan Básico.\n\nPuedes mejorar cuando lo desees.'
              : 'No se pudo cambiar el plan. Intenta de nuevo.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
