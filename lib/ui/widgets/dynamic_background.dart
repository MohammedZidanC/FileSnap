import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../providers/settings_provider.dart';

/// A lightweight animated background with theme gradient + drifting particles.
/// Particles pause when idle (no interaction for 2s). Max 20 particles.
class DynamicBackground extends ConsumerStatefulWidget {
  final LayeredColors colors;
  final Widget child;

  const DynamicBackground({super.key, required this.colors, required this.child});

  @override
  ConsumerState<DynamicBackground> createState() => _DynamicBackgroundState();
}

class _DynamicBackgroundState extends ConsumerState<DynamicBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();
  DateTime _lastInteraction = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Generate 30 particles with boosted visibility
    _particles = List.generate(30, (_) => _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      radius: _random.nextDouble() * 2.5 + 1.0,
      speed: _random.nextDouble() * 0.02 + 0.005,
      // Increased opacity from [0.05-0.22] up to [0.3-0.55]
      opacity: _random.nextDouble() * 0.25 + 0.3,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onInteraction() {
    _lastInteraction = DateTime.now();
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read the toggle from SettingsProvider (which DynamicBackground must import)
    final showGlow = ref.watch(settingsProvider).showParticleGlow;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onInteraction(),
      onPointerMove: (_) => _onInteraction(),
      child: Stack(
        children: [
          // Base gradient layer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.colors.background,
                    widget.colors.surface,
                    widget.colors.background,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Particle layer
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Pause particles if idle for 2 seconds
                final idleMs = DateTime.now().difference(_lastInteraction).inMilliseconds;
                if (idleMs > 2000 && _controller.isAnimating) {
                  // Don't stop abruptly, just let them drift very slowly
                }

                return CustomPaint(
                  painter: _ParticlePainter(
                    particles: _particles,
                    tick: _controller.value,
                    color: widget.colors.accent,
                    idleMs: idleMs,
                    glow: showGlow,
                  ),
                );
              },
            ),
          ),

          // Content
          widget.child,
        ],
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  final double radius;
  final double speed;
  final double opacity;

  _Particle({required this.x, required this.y, required this.radius, required this.speed, required this.opacity});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double tick;
  final Color color;
  final int idleMs;
  final bool glow;

  _ParticlePainter({required this.particles, required this.tick, required this.color, required this.idleMs, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    // Reduce intensity when idle
    final intensityFactor = idleMs > 2000 ? 0.3 : 1.0;

    for (var p in particles) {
      // Drift upward slowly
      p.y -= p.speed * intensityFactor * 0.5;
      // Slight horizontal sway
      p.x += sin(tick * 2 * pi + p.y * 10) * 0.001 * intensityFactor;

      // Wrap around
      if (p.y < -0.05) {
        p.y = 1.05;
      }
      if (p.x < 0) p.x = 1.0;
      if (p.x > 1) p.x = 0.0;

      final paint = Paint()
        ..color = color.withValues(alpha: p.opacity * intensityFactor)
        ..style = PaintingStyle.fill;
        
      if (glow) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      }

      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
