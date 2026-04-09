import 'package:flutter/material.dart';

// ─── Animated Background Blobs ────────────────────────────────────────────────
// Empty - background removed for clean white look
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
    return const SizedBox.shrink();
  }
}
