import 'package:flutter/material.dart';
import 'image_editor_screen.dart';

class WatermarkToolScreen extends StatefulWidget {
  const WatermarkToolScreen({super.key});
  @override
  State<WatermarkToolScreen> createState() => _WatermarkToolScreenState();
}

class _WatermarkToolScreenState extends State<WatermarkToolScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ImageEditorScreen(initialMode: 'watermark')),
      );
    });
  }
  @override
  Widget build(BuildContext context) => const Scaffold();
}
