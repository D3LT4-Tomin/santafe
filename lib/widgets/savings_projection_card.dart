import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─── Data ─────────────────────────────────────────────────────────────────────
class SavingsProjectionData {
  final double projectedAmount;
  final double rangeMin;
  final double rangeMax;
  final double currentSavings;
  final int currentAge;
  final int targetAge;

  const SavingsProjectionData({
    this.projectedAmount = 563338,
    this.rangeMin = 525000,
    this.rangeMax = 600000,
    this.currentSavings = 144,
    this.currentAge = 20,
    this.targetAge = 65,
  });
}

// ─── Card ─────────────────────────────────────────────────────────────────────
class SavingsProjectionCard extends StatefulWidget {
  final SavingsProjectionData data;
  const SavingsProjectionCard({super.key, this.data = const SavingsProjectionData()});

  @override
  State<SavingsProjectionCard> createState() => _SavingsProjectionCardState();
}

class _SavingsProjectionCardState extends State<SavingsProjectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _chartController;
  late Animation<double> _chartAnim;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _chartAnim = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _chartController.forward();
    });
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x12FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionLabel('PROYECCIÓN DE AHORRO'),
                _SmartBadge(),
              ],
            ),
            const SizedBox(height: 16),

            // Big number
            const Text(
              'A los 65 años podrías tener',
              style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93), height: 1.4),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '\$${_formatAmount(d.projectedAmount)}',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFFFFF),
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showInfoDialog(context),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x30FFFFFF)),
                    ),
                    child: const Center(
                      child: Text('?',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFAAAAAA))),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Range + current row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rango esperado',
                          style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
                      const SizedBox(height: 3),
                      Text(
                        '\$${_formatK(d.rangeMin)} – \$${_formatK(d.rangeMax)}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFFFFF),
                            letterSpacing: -0.3),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hoy llevas',
                          style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
                      const SizedBox(height: 3),
                      Text(
                        '\$${d.currentSavings.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFFFFF),
                            letterSpacing: -0.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Chart
            SizedBox(
              height: 150,
              child: AnimatedBuilder(
                animation: _chartAnim,
                builder: (_, __) => CustomPaint(
                  painter: _SavingsChartPainter(
                    progress: _chartAnim.value,
                    currentAge: d.currentAge,
                    targetAge: d.targetAge,
                    currentSavings: d.currentSavings,
                    projected: d.projectedAmount,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),

            // Age labels
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('A tus 20',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
                  Text('A tus 65',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Insight
            _InsightBox(
              text:
                  'Ahorrando \$450/mes con un retorno anual del 7%, alcanzarías \$563K a los 65. Cada año que empieces antes puede añadir ~\$40K.',
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('¿Cómo se calcula?',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text(
          'Basado en tu ahorro actual de \$450/mes con un retorno anual estimado del 7%, compuesto mensualmente desde los 20 hasta los 65 años.',
          style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido', style: TextStyle(color: Color(0xFF0A84FF))),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) {
      final s = v.toStringAsFixed(0);
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return v.toStringAsFixed(0);
  }

  String _formatK(double v) => '${(v / 1000).toStringAsFixed(0)}K';
}

// ─── Chart Painter ─────────────────────────────────────────────────────────────
class _SavingsChartPainter extends CustomPainter {
  final double progress;
  final int currentAge;
  final int targetAge;
  final double currentSavings;
  final double projected;

  const _SavingsChartPainter({
    required this.progress,
    required this.currentAge,
    required this.targetAge,
    required this.currentSavings,
    required this.projected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final years = targetAge - currentAge;
    final points = years + 1;

    // Generate main curve (compound growth + realistic noise)
    final mainValues = List.generate(points, (i) {
      final t = i.toDouble();
      final base = currentSavings * math.pow(1.07, t / 1);
      // Add monthly contributions compounded
      final contributions = 450 * 12 * (math.pow(1.07, t / 1) - 1) / 0.07;
      final wave = math.sin(t * 0.85) * (t * 6);
      return (base + contributions + wave).clamp(0.0, double.infinity);
    });

    final maxVal = projected * 1.12;

    List<Offset> toPoints(List<double> vals) {
      return List.generate(vals.length, (i) {
        final x = size.width * i / (vals.length - 1);
        final y = size.height - (vals[i] / maxVal * size.height);
        return Offset(x, y);
      });
    }

    final mainPts = toPoints(mainValues);
    final highPts = toPoints(mainValues.map((v) => v * 1.09).toList());
    final lowPts = toPoints(mainValues.map((v) => v * 0.93).toList());

    // Clip to progress
    final clipWidth = size.width * progress;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, clipWidth, size.height));

    // Band fill
    final bandPath = Path();
    bandPath.moveTo(highPts.first.dx, highPts.first.dy);
    for (int i = 1; i < highPts.length; i++) {
      final cp1 = Offset((highPts[i - 1].dx + highPts[i].dx) / 2, highPts[i - 1].dy);
      final cp2 = Offset((highPts[i - 1].dx + highPts[i].dx) / 2, highPts[i].dy);
      bandPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, highPts[i].dx, highPts[i].dy);
    }
    for (int i = lowPts.length - 1; i >= 0; i--) {
      final prev = i < lowPts.length - 1 ? lowPts[i + 1] : lowPts[i];
      final cp1 = Offset((prev.dx + lowPts[i].dx) / 2, prev.dy);
      final cp2 = Offset((prev.dx + lowPts[i].dx) / 2, lowPts[i].dy);
      bandPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, lowPts[i].dx, lowPts[i].dy);
    }
    bandPath.close();

    canvas.drawPath(
        bandPath,
        Paint()
          ..color = const Color(0xFF0A84FF).withOpacity(0.15)
          ..style = PaintingStyle.fill);

    // Main line
    final linePath = Path();
    linePath.moveTo(mainPts.first.dx, mainPts.first.dy);
    for (int i = 1; i < mainPts.length; i++) {
      final cp1 = Offset((mainPts[i - 1].dx + mainPts[i].dx) / 2, mainPts[i - 1].dy);
      final cp2 = Offset((mainPts[i - 1].dx + mainPts[i].dx) / 2, mainPts[i].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, mainPts[i].dx, mainPts[i].dy);
    }
    canvas.drawPath(
        linePath,
        Paint()
          ..color = const Color(0xFF1D5FB8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SavingsChartPainter old) => old.progress != progress;
}

// ─── Shared small widgets ──────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: Color(0xFF8E8E93),
        height: 1.33,
      ),
    );
  }
}

class _SmartBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x1A0A84FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x330A84FF), width: 0.5),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          'SMART INSIGHTS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Color(0xFF0A84FF),
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _InsightBox extends StatelessWidget {
  final String text;
  const _InsightBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x0F0A84FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x260A84FF), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8E8E93),
            height: 1.55,
          ),
        ),
      ),
    );
  }
}
