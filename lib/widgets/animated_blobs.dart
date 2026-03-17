import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

// ─── Animated Background Blobs ────────────────────────────────────────────────
class AnimatedBlobs extends StatelessWidget {
  final Animation<double> blob1Anim;
  final Animation<double> blob2Anim;

  const AnimatedBlobs({
    super.key,
    required this.blob1Anim,
    required this.blob2Anim,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([blob1Anim, blob2Anim]),
      builder: (context, _) {
        return Stack(
          children: [
            Positioned(
              top: -180 + blob1Anim.value * 40,
              left: -80 + blob1Anim.value * 30,
              child: Transform.rotate(
                angle: blob1Anim.value * math.pi * 0.5,
                child: Container(
                  width: 480, height: 480,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x2E2563EB),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 400 - blob2Anim.value * 50,
              right: -180 - blob2Anim.value * 20,
              child: Transform.rotate(
                angle: -blob2Anim.value * math.pi * 0.4,
                child: Container(
                  width: 560, height: 560,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x26581C87),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
