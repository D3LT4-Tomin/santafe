import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        Colors,
        Material,
        DraggableScrollableSheet,
        MaterialLocalizations,
        showModalBottomSheet,
        Divider,
        ReorderableListView;
import 'package:provider/provider.dart';

import 'insights_layout_controller.dart';

Future<void> showCustomizeSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Material(
      color: Colors.transparent,
      child: ChangeNotifierProvider.value(
        value: context.read<InsightsLayoutController>(),
        child: const _CustomizeSheet(),
      ),
    ),
  );
}

class _CustomizeSheet extends StatelessWidget {
  const _CustomizeSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.60,
      minChildSize: 0.40,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF48484A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Personalizar sección',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Listo',
                        style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFF0A84FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF38383A), height: 1),
              // Subtitle hint
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Arrastra para reordenar · Toca el interruptor para mostrar u ocultar',
                  style: TextStyle(fontSize: 12, color: Color(0xFF636366)),
                ),
              ),
              // List
              Expanded(
                child: Consumer<InsightsLayoutController>(
                  builder: (context, controller, _) {
                    return ReorderableListView.builder(
                      scrollController: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: controller.configs.length,
                      onReorder: controller.reorder,
                      proxyDecorator: (child, index, animation) {
                        return Material(
                          color: Colors.transparent,
                          child: ScaleTransition(
                            scale: animation.drive(
                              Tween(
                                begin: 1.0,
                                end: 1.03,
                              ).chain(CurveTween(curve: Curves.easeOutCubic)),
                            ),
                            child: child,
                          ),
                        );
                      },
                      itemBuilder: (context, index) {
                        final config = controller.configs[index];
                        return _WidgetListItem(
                          key: ValueKey(config.id),
                          config: config,
                          onToggle: (val) =>
                              controller.setVisible(config.id, val),
                        );
                      },
                    );
                  },
                ),
              ),
              // Reset button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      context.read<InsightsLayoutController>().reset();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Restablecer orden predeterminado',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF0A84FF),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WidgetListItem extends StatelessWidget {
  final InsightWidgetConfig config;
  final ValueChanged<bool> onToggle;

  const _WidgetListItem({
    super.key,
    required this.config,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C1C1E),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                // Drag handle
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(
                    CupertinoIcons.line_horizontal_3,
                    color: Color(0xFF636366),
                    size: 20,
                  ),
                ),
                // Name
                Expanded(
                  child: Text(
                    config.id.displayName,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                // Toggle
                CupertinoSwitch(
                  value: config.visible,
                  activeTrackColor: const Color(0xFF34C759),
                  onChanged: onToggle,
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF38383A), height: 1, indent: 56),
        ],
      ),
    );
  }
}
