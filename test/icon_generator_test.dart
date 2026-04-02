import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Generate icon image', (WidgetTester tester) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    final size = const Size(1024, 1024);
    
    // Draw background
    final bgPaint = Paint()..color = const Color(0xFF1E1E1E); // nice dark gray
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final fStemPath = Path()
      ..moveTo(-55, -50)
      ..quadraticBezierTo(-70, 10, -45, 60);

    final fTopPath = Path()
      ..moveTo(-55, -50)
      ..cubicTo(-30, -80, 0, -30, 20, -55);

    final fMidPath = Path()
      ..moveTo(-60, -5)
      ..quadraticBezierTo(-30, 20, 5, 0);

    final sCurvePath = Path()
      ..moveTo(40, -45)
      ..cubicTo(0, -80, -10, -25, 15, -5) 
      ..cubicTo(40, 15, 45, 75, -5, 50);  

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(4.0); 

    // Blue accent
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF4A90E2) 
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF4A90E2).withOpacity(0.4)
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

    canvas.drawPath(fStemPath, glowPaint);
    canvas.drawPath(fStemPath, strokePaint);
    
    canvas.drawPath(fTopPath, glowPaint);
    canvas.drawPath(fTopPath, strokePaint);
    
    canvas.drawPath(fMidPath, glowPaint);
    canvas.drawPath(fMidPath, strokePaint);
    
    canvas.drawPath(sCurvePath, glowPaint);
    canvas.drawPath(sCurvePath, strokePaint);
    
    canvas.restore();

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final file = File('assets/icon.png');
    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }
    file.writeAsBytesSync(buffer);
  });
}
