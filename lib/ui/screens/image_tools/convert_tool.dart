import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import '../../../services/storage_service.dart';
import 'package:path/path.dart' as p;

class ConvertToolScreen extends StatefulWidget {
  const ConvertToolScreen({super.key});

  @override
  State<ConvertToolScreen> createState() => _ConvertToolScreenState();
}

class _ConvertToolScreenState extends State<ConvertToolScreen> {
  File? _originalFile;
  String _targetFormat = 'PNG';
  bool _isProcessing = false;
  String _status = "";

  Future<void> _pickImage() async {
    final xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xfile != null) {
      setState(() {
        _originalFile = File(xfile.path);
        _status = "";
      });
    }
  }

  Future<void> _convertFile() async {
    if (_originalFile == null) return;
    setState(() => _isProcessing = true);
    try {
      final finalDir = await StorageService.getImagesDirectory();
      final baseName = 'converted_${DateTime.now().millisecondsSinceEpoch}';

      if (_targetFormat == 'PDF') {
        final pdf = pw.Document();
        final image = pw.MemoryImage(_originalFile!.readAsBytesSync());
        pdf.addPage(pw.Page(build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        }));
        final file = File(p.join(finalDir.path, '$baseName.pdf'));
        await file.writeAsBytes(await pdf.save());
        setState(() => _status = "Saved as PDF!");
      } else {
        // use image package
        final bytes = await _originalFile!.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image == null) throw Exception("Cannot decode image");

        File file;
        if (_targetFormat == 'PNG') {
          file = File(p.join(finalDir.path, '$baseName.png'));
          await file.writeAsBytes(img.encodePng(image));
        } else if (_targetFormat == 'JPG') {
          file = File(p.join(finalDir.path, '$baseName.jpg'));
          await file.writeAsBytes(img.encodeJpg(image, quality: 90));
        } else if (_targetFormat == 'WEBP') {
          file = File(p.join(finalDir.path, '$baseName.webp')); // native flutter doesn't encode webp easily in dart, but we'll try or fallback
          // wait, image package might not encode webp, but there's a workaround.
          // image package doesn't support emit webp currently? Actually flutter_image_compress does.
          throw Exception("WEBP via pure dart is limited. Use JPG/PNG/PDF.");
        }
        setState(() => _status = "Saved successfully!");
      }
    } catch (e) {
      setState(() => _status = e.toString());
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Convert Format")),
      body: _isProcessing 
        ? const Center(child: CircularProgressIndicator()) 
        : Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(onPressed: _pickImage, child: const Text("Select Image")),
                if (_originalFile != null) ...[
                  const SizedBox(height: 16),
                  Text("Selected: ${p.basename(_originalFile!.path)}"),
                ],
                const SizedBox(height: 32),
                DropdownButton<String>(
                  value: _targetFormat,
                  items: ['JPG', 'PNG', 'PDF', 'WEBP'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _targetFormat = val!),
                ),
                const SizedBox(height: 32),
                ElevatedButton(onPressed: _convertFile, child: const Text("CONVERT")),
                if (_status.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 24), child: Text(_status, textAlign: TextAlign.center, style: const TextStyle(color: Colors.green))),
              ],
            ),
          ),
    );
  }
}
