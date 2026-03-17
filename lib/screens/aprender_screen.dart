import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_blobs.dart';
import '../widgets/header_row.dart';

class AprenderScreen extends StatefulWidget {
  const AprenderScreen({super.key});

  @override
  State<AprenderScreen> createState() => _AprenderScreenState();
}

class _AprenderScreenState extends State<AprenderScreen>
    with TickerProviderStateMixin {
  late AnimationController _blob1Controller;
  late AnimationController _blob2Controller;
  late Animation<double>   _blob1Anim;
  late Animation<double>   _blob2Anim;

  final _searchBarOpacity = ValueNotifier<double>(1.0);

  @override
  void initState() {
    super.initState();
    _blob1Controller = AnimationController(
      vsync: this, duration: const Duration(seconds: 25),
    )..repeat(reverse: true);
    _blob2Controller = AnimationController(
      vsync: this, duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
    _blob1Anim = CurvedAnimation(parent: _blob1Controller, curve: Curves.easeInOut);
    _blob2Anim = CurvedAnimation(parent: _blob2Controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _blob1Controller.dispose();
    _blob2Controller.dispose();
    _searchBarOpacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.systemBackground,
      child: Stack(
        children: [
          RepaintBoundary(
            child: AnimatedBlobs(blob1Anim: _blob1Anim, blob2Anim: _blob2Anim),
          ),

          // ── Placeholder content ──────────────────────────────────
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.white05,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.white10),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Icon(
                        CupertinoIcons.book_fill,
                        color: AppColors.systemPurple,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Aprender', style: AppTextStyles.title3),
                  const SizedBox(height: 6),
                  const Text(
                    'Próximamente',
                    style: AppTextStyles.subheadline,
                  ),
                ],
              ),
            ),
          ),

          // ── Header ───────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: IgnorePointer(child: _buildHeaderChrome(topPadding)),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding + 10, bottom: 20, left: 16, right: 8,
              ),
              child: HeaderRow(searchBarOpacity: _searchBarOpacity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChrome(double topPadding) {
    return SizedBox(
      height: topPadding + 66.0,
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                  colors: [AppColors.frostedBlue, Color(0x00070D1A)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
