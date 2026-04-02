import 'package:flutter/material.dart';
import 'image_editor_screen.dart';

class CropToolScreen extends StatefulWidget {
  const CropToolScreen({super.key});
  @override
  State<CropToolScreen> createState() => _CropToolScreenState();
}

class _CropToolScreenState extends State<CropToolScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ImageEditorScreen(initialMode: 'crop')),
      );
    });
  }
  @override
  Widget build(BuildContext context) => const Scaffold();
}
