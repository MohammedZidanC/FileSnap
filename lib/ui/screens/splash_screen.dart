import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:async';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import 'home_screen.dart';
import 'setup_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool hasNavigated = false;

  // Precomputed geometry
  late final Path _fStemPath;
  late final PathMetric _fStemMetric;
  late final Path _fTopPath;
  late final PathMetric _fTopMetric;
  late final Path _fMidPath;
  late final PathMetric _fMidMetric;
  
  late final Path _sCurvePath;
  late final PathMetric _sCurveMetric;

  // Shared reusable paints
  late final Paint _bgPaint;
  late final Paint _rippleGlowPaint;
  late final Paint _strokePaint;
  late final Paint _glowPaint;
  late final Paint _holdGlowPaint;

  @override
  void initState() {
    super.initState();
    
    // 3. Precompute fixed curves/paths once to prevent recalculation inside build()
    // Shift F to the left by ~25 units
    _fStemPath = Path()
      ..moveTo(-55, -50)
      ..quadraticBezierTo(-70, 10, -45, 60);
    _fStemMetric = _fStemPath.computeMetrics().first;

    _fTopPath = Path()
      ..moveTo(-55, -50)
      ..cubicTo(-30, -80, 0, -30, 20, -55);
    _fTopMetric = _fTopPath.computeMetrics().first;

    _fMidPath = Path()
      ..moveTo(-60, -5)
      ..quadraticBezierTo(-30, 20, 5, 0);
    _fMidMetric = _fMidPath.computeMetrics().first;

    // The 'S' curve shifted right
    _sCurvePath = Path()
      ..moveTo(40, -45)
      ..cubicTo(0, -80, -10, -25, 15, -5) // Top curl
      ..cubicTo(40, 15, 45, 75, -5, 50);  // Bottom curl
    _sCurveMetric = _sCurvePath.computeMetrics().first;

    // Cache static paint configurations
    _bgPaint = Paint();
    _rippleGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0);
    
    _strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      
    _holdGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);

    // 6. Efficient animation configuration
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToHome();
      }
    });

    // 7. Add fallback navigation (Guarantee app does not freeze)
    Future.delayed(const Duration(seconds: 3), () {
      _goToHome();
    });

    _controller.forward();
  }

  void _goToHome() {
    if (hasNavigated) return;
    hasNavigated = true;

    try {
      final settings = ref.read(settingsProvider);
      
      if (!settings.hasCompletedSetup) {
         Navigator.of(context).pushReplacement(
           MaterialPageRoute(builder: (_) => const SetupScreen()),
         );
         return;
      }
    } catch (e) {
      debugPrint("Settings read failed, recovering. Error: $e");
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isLight = true;
    var startingBgColor = Colors.white;
    Color accentColor = Colors.blue;
    Color targetBgColor = Colors.white;

    try {
      final themeMode = ref.watch(settingsProvider).themeMode;
      isLight = themeMode == AppThemeMode.light || themeMode == AppThemeMode.slateSand || themeMode == AppThemeMode.oceanTeal; 
      startingBgColor = isLight ? Colors.white : const Color(0xFF030303);
      final themeColors = AppTheme.getColors(themeMode);
      accentColor = themeColors.accent;
      targetBgColor = themeColors.background;
    } catch (e) {
      debugPrint("Theme fetch failed, using fallback colors.");
    }

    return Scaffold(
      backgroundColor: startingBgColor,
      // 1. Wrap animation root in RepaintBoundary
      body: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: SplashAnimatorPainter(
                progress: _controller.value,
                accentColor: accentColor,
                targetBgColor: targetBgColor,
                fStemPath: _fStemPath,
                fStemMetric: _fStemMetric,
                fTopPath: _fTopPath,
                fTopMetric: _fTopMetric,
                fMidPath: _fMidPath,
                fMidMetric: _fMidMetric,
                sCurvePath: _sCurvePath,
                sCurveMetric: _sCurveMetric,
                bgPaint: _bgPaint,
                rippleGlowPaint: _rippleGlowPaint,
                strokePaint: _strokePaint,
                glowPaint: _glowPaint,
                holdGlowPaint: _holdGlowPaint,
              ),
              // 5. Use const widgets wherever possible
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

// 4. Ensure CustomPainter is lightweight
class SplashAnimatorPainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final Color targetBgColor;

  final Path fStemPath;
  final PathMetric fStemMetric;
  final Path fTopPath;
  final PathMetric fTopMetric;
  final Path fMidPath;
  final PathMetric fMidMetric;
  final Path sCurvePath;
  final PathMetric sCurveMetric;

  final Paint bgPaint;
  final Paint rippleGlowPaint;
  final Paint strokePaint;
  final Paint glowPaint;
  final Paint holdGlowPaint;

  // Cached dynamic entry path avoiding frame-by-frame memory allocation
  static Path? _cachedEntryPath;
  static PathMetric? _cachedEntryMetric;
  static double _cachedWidth = 0;

  SplashAnimatorPainter({
    required this.progress,
    required this.accentColor,
    required this.targetBgColor,
    required this.fStemPath,
    required this.fStemMetric,
    required this.fTopPath,
    required this.fTopMetric,
    required this.fMidPath,
    required this.fMidMetric,
    required this.sCurvePath,
    required this.sCurveMetric,
    required this.bgPaint,
    required this.rippleGlowPaint,
    required this.strokePaint,
    required this.glowPaint,
    required this.holdGlowPaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 2. Heavy calculations removed, using cached metrics instead
    final center = Offset(size.width * 0.5, size.height * 0.5);

    // Ripple
    final rippleProgress = ((progress - 0.85) * 6.666666).clamp(0.0, 1.0);
    if (rippleProgress > 0) {
      final maxRadius = math.sqrt(size.width * size.width + size.height * size.height);
      final currentRadius = maxRadius * Curves.easeOutQuad.transform(rippleProgress);
      
      bgPaint.color = targetBgColor;
      canvas.drawCircle(center, currentRadius, bgPaint);
      
      rippleGlowPaint
        ..color = accentColor.withOpacity(1.0 - rippleProgress)
        ..strokeWidth = 20.0 * (1.0 - rippleProgress);
      
      canvas.drawCircle(center, currentRadius, rippleGlowPaint);
    }

    double scale = 1.0;
    double dy = 0.0;
    
    // Scale and Shift Math
    if (progress >= 0.65 && progress < 0.75) {
      final p = (progress - 0.65) * 10.0;
      scale = 1.0 + 0.1 * Curves.easeOutCubic.transform(p);
    } else if (progress >= 0.75) {
      scale = 1.1;
      final p = ((progress - 0.75) * 10.0).clamp(0.0, 1.0);
      dy = 12.0 * math.sin(p * math.pi); 
    }
    
    canvas.save();
    canvas.translate(center.dx, center.dy + dy);
    canvas.scale(scale);

    final baseOpacity = (1.0 - (rippleProgress * 1.5)).clamp(0.0, 1.0);

    // Soft update of pre-instantiated Paints
    strokePaint.color = accentColor.withOpacity(baseOpacity);
    
    glowPaint
      ..color = accentColor.withOpacity(baseOpacity * 0.4)
      ..strokeWidth = 6.0;

    // Entry Curve Render
    final p1 = (progress * 4.0).clamp(0.0, 1.0);
    if (p1 > 0 && progress < 0.4) {
      if (_cachedEntryPath == null || _cachedWidth != size.width) {
        _cachedWidth = size.width;
        _cachedEntryPath = Path()
          ..moveTo(-size.width, 0)
          ..cubicTo(-size.width * 0.5, -150, -size.width * 0.25, 150, -30, -50);
        _cachedEntryMetric = _cachedEntryPath!.computeMetrics().first;
      }
      
      final end = _cachedEntryMetric!.length * Curves.easeOut.transform(p1);
      final start = math.max(0.0, end - (_cachedEntryMetric!.length * 0.25));
      
      strokePaint.strokeWidth = 2.0;
      final segment = _cachedEntryMetric!.extractPath(start, end);
      canvas.drawPath(segment, glowPaint);
      canvas.drawPath(segment, strokePaint);
    }

    strokePaint.strokeWidth = 4.0;
    
    // Path extraction directly from pre-computed metrics
    final p2 = ((progress - 0.25) * 10.0).clamp(0.0, 1.0);
    if (p2 > 0) {
      final extract = fStemMetric.extractPath(0, fStemMetric.length * Curves.easeInOut.transform(p2));
      canvas.drawPath(extract, glowPaint);
      canvas.drawPath(extract, strokePaint);
    }

    final p3 = ((progress - 0.3) * 10.0).clamp(0.0, 1.0);
    if (p3 > 0) {
      final extract = fTopMetric.extractPath(0, fTopMetric.length * Curves.easeInOut.transform(p3));
      canvas.drawPath(extract, glowPaint);
      canvas.drawPath(extract, strokePaint);
    }

    final p4 = ((progress - 0.4) * 10.0).clamp(0.0, 1.0);
    if (p4 > 0) {
      final extract = fMidMetric.extractPath(0, fMidMetric.length * Curves.easeInOut.transform(p4));
      canvas.drawPath(extract, glowPaint);
      canvas.drawPath(extract, strokePaint);
    }
    
    // Draw S path
    final p5 = ((progress - 0.35) * 10.0).clamp(0.0, 1.0);
    if (p5 > 0) {
      final extract = sCurveMetric.extractPath(0, sCurveMetric.length * Curves.easeInOut.transform(p5));
      canvas.drawPath(extract, glowPaint);
      canvas.drawPath(extract, strokePaint);
    }
    
    // Pulse Render
    if (progress >= 0.5 && progress < 0.65) {
       final pulseP = (progress - 0.5) * 6.666666;
       final pulseValue = math.sin(pulseP * math.pi);
       
       holdGlowPaint
         ..color = accentColor.withOpacity(0.4 * pulseValue * baseOpacity)
         ..strokeWidth = 10.0 + 15.0 * pulseValue;
         
       canvas.drawPath(fStemPath, holdGlowPaint);
       canvas.drawPath(fTopPath, holdGlowPaint);
       canvas.drawPath(fMidPath, holdGlowPaint);
       canvas.drawPath(sCurvePath, holdGlowPaint);
    }

    // Fade in text 'FileSnap'
    if (progress > 0.4) {
      final textOp = ((progress - 0.4) * 2.5).clamp(0.0, 1.0);
      final textSpan = TextSpan(
        text: 'FileSnap',
        style: TextStyle(
          color: accentColor.withOpacity(textOp * baseOpacity),
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: 4.0,
          fontFamily: 'Inter',
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, 90));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SplashAnimatorPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accentColor != accentColor || oldDelegate.targetBgColor != targetBgColor;
  }
}
