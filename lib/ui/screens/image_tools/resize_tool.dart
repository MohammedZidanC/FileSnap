import 'dart:io';
import 'package:flutter/material.dart';
import '../../widgets/processing_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/image_service.dart';

class ResizeToolScreen extends StatefulWidget {
  const ResizeToolScreen({super.key});

  @override
  State<ResizeToolScreen> createState() => _ResizeToolScreenState();
}

class _ResizeToolScreenState extends State<ResizeToolScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final TextEditingController _targetController = TextEditingController();
  String _unit = 'KB';
  
  bool _isProcessing = false;
  double _progress = 0;
  
  File? _resultFile;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _resultFile = null;
      });
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;
    if (_targetController.text.isEmpty) {
      _showError("Enter a target size");
      return;
    }

    double targetValue = double.tryParse(_targetController.text) ?? 0;
    if (targetValue <= 0) {
      _showError("Enter a valid number");
      return;
    }

    double targetKB = _unit == 'MB' ? targetValue * 1024 : targetValue;

    setState(() {
      _isProcessing = true;
      _progress = 0.5;
    });

    try {
      final finalFile = await ImageService.resizeImageToTargetList(
        originalFile: _selectedImage!,
        targetKB: targetKB,
      );

      setState(() {
        _isProcessing = false;
        _progress = 1.0;
        _resultFile = finalFile;
      });
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resize Image")),
      body: _isProcessing ? _buildProcessingScreen() : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 64, color: Theme.of(context).primaryColor),
                        const SizedBox(height: 16),
                        const Text("Select Image"),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target Size',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  initialValue: _unit,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: ['KB', 'MB'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _unit = val!);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _selectedImage == null ? null : _processImage,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text("RESIZE NOW"),
            ),
          ),
          
          if (_resultFile != null) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text("Success", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Saved to: ${_resultFile!.path}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildProcessingScreen() {
    return ProcessingScreen(progress: _progress);
  }
}
