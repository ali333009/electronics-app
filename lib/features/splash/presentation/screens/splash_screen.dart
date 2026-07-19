import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Logo: scale + fade ──────────────────────────────────────────
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // ── Shimmer sweep across the whole logo ─────────────────────────
  late final AnimationController _shimmerController;

  // ── Exit: fade out whole screen ─────────────────────────────────
  late final AnimationController _exitController;
  late final Animation<double> _exitOpacity;

  String? _logoUrl;

  @override
  void initState() {
    super.initState();

    // 1) Logo reveal — 750 ms
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _logoScale = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );

    // 2) Shimmer sweep — loops across the logo image
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // 3) Exit fade — 400 ms
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _startSequence();
  }

  Future<void> _fetchLogoUrl() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('settings').doc('general').get();
      if (doc.exists && doc.data() != null) {
        final url = doc.data()!['appLogoUrl'] as String?;
        if (url != null && url.isNotEmpty) {
          if (mounted) {
            setState(() {
              _logoUrl = url;
            });
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _startSequence() async {
    // Wait for logo URL then pre-cache the image so it's ready when displayed
    await _fetchLogoUrl();
    if (_logoUrl != null && mounted) {
      await precacheImage(NetworkImage(_logoUrl!), context);
    }
    
    // Now that everything is loaded and our screen is at 100% opacity, we hide the native OS splash.
    FlutterNativeSplash.remove();

    // step 1 — logo pops in (already at 1.0 scale/opacity now to prevent flash)
    await _logoController.forward();

    // step 2 — shimmer sweeps across logo (2 passes)
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _shimmerController.repeat();
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    _shimmerController.stop();

    // step 3 — hold briefly, then exit
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await _exitController.forward();

    if (mounted) context.go(Routes.home);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _shimmerController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always use white background — the logo PNG itself has white bg
    // so we match it perfectly in both light & dark system modes.
    const bg = Color(0xFFF8F6F3);

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _exitOpacity,
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _logoController,
              _shimmerController,
            ]),
            builder: (context, _) {
              return ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: _ShimmerLogo(
                    shimmerProgress: _shimmerController.value,
                    child: _logoUrl != null
                      ? Image.network(
                          _logoUrl!,
                          width: 300,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/elctronicEmg.png',
                            width: 300,
                            filterQuality: FilterQuality.high,
                          ),
                        )
                      : Image.asset(
                          'assets/images/elctronicEmg.png',
                          width: 300,
                          filterQuality: FilterQuality.high,
                        ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Overlays a diagonal shimmer highlight that sweeps left→right across [child].
class _ShimmerLogo extends StatelessWidget {
  const _ShimmerLogo({
    required this.shimmerProgress,
    required this.child,
  });

  final double shimmerProgress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        // Sweep position: maps [0,1] → from far left to far right
        final double sweep =
            (math.sin(shimmerProgress * math.pi) + 1) / 2; // ease in/out
        final double center = bounds.left - 80 + (bounds.width + 160) * sweep;

        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Colors.transparent,
            Colors.transparent,
            Color(0x55FFFFFF), // soft white sheen
            Color(0x99FFFFFF), // bright center
            Color(0x55FFFFFF),
            Colors.transparent,
            Colors.transparent,
          ],
          stops: [
            0.0,
            ((center - 60) / bounds.width).clamp(0.0, 1.0),
            ((center - 20) / bounds.width).clamp(0.0, 1.0),
            (center / bounds.width).clamp(0.0, 1.0),
            ((center + 20) / bounds.width).clamp(0.0, 1.0),
            ((center + 60) / bounds.width).clamp(0.0, 1.0),
            1.0,
          ],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
