import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../../../services/storage_service.dart';

class ImageEditorScreen extends StatefulWidget {
  final String initialMode;
  const ImageEditorScreen({super.key, this.initialMode = 'filters'});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  final List<File> _images = [];
  int _currentIndex = 0;
  String _activeTab = 'filters';

  // State arrays parallel to _images
  final List<List<double>> _colorMatrices = [];
  final List<int> _rotations = [];
  
  // Watermark
  String _watermarkText = "FileSnap";
  double _watermarkOpacity = 0.5;
  Color _watermarkColor = Colors.white;
  Alignment _watermarkAlignment = Alignment.center;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialMode;
    _pickImages();
  }

  Future<void> _pickImages() async {
    final xfiles = await ImagePicker().pickMultiImage();
    if (xfiles.isNotEmpty && mounted) {
      setState(() {
        for (var x in xfiles) {
          _images.add(File(x.path));
          _colorMatrices.add(_Filters.normal);
          _rotations.add(0);
        }
      });
    } else if (_images.isEmpty && mounted) {
      Navigator.pop(context);
    }
  }

  void _nextImage() {
    if (_currentIndex < _images.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _prevImage() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  void _deleteCurrent() {
    setState(() {
      _images.removeAt(_currentIndex);
      _colorMatrices.removeAt(_currentIndex);
      _rotations.removeAt(_currentIndex);
      if (_currentIndex >= _images.length && _currentIndex > 0) {
        _currentIndex--;
      }
    });
    if (_images.isEmpty) Navigator.pop(context);
  }

  Future<void> _saveAndShare() async {
    // Save to /FileSnap/Images
    try {
      final dir = await StorageService.getImagesDirectory();
      List<String> savedPaths = [];
      for (int i = 0; i < _images.length; i++) {
        // Just copying current for simulation, proper export requires Canvas compilation
        final name = 'Edited_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final newPath = '${dir.path}/$name';
        await _images[i].copy(newPath);
        savedPaths.add(newPath);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to ${dir.path}')));
        final xfiles = savedPaths.map((p) => XFile(p)).toList();
        await Share.shareXFiles(xfiles, text: 'Edited with FileSnap');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_images.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / ${_images.length}'),
        actions: [
          IconButton(icon: const Icon(LucideIcons.check), onPressed: _saveAndShare),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'Apply All Filters') {
                setState(() {
                  for (int i = 0; i < _colorMatrices.length; i++) {
                    _colorMatrices[i] = _colorMatrices[_currentIndex];
                  }
                });
              } else if (v == 'Apply All Rotations') {
                setState(() {
                  for (int i = 0; i < _rotations.length; i++) {
                    _rotations[i] = _rotations[_currentIndex];
                  }
                });
              } else if (v == 'Delete') {
                _deleteCurrent();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'Apply All Filters', child: Text('Apply Filter to All')),
              const PopupMenuItem(value: 'Apply All Rotations', child: Text('Apply Rotation to All')),
              const PopupMenuItem(value: 'Delete', child: Text('Delete Image', style: TextStyle(color: Colors.red))),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) _prevImage();
                else if (details.primaryVelocity! < 0) _nextImage();
              },
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.black12),
                  RotatedBox(
                    quarterTurns: _rotations[_currentIndex],
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(_colorMatrices[_currentIndex]),
                      child: Image.file(_images[_currentIndex], fit: BoxFit.contain),
                    ),
                  ),
                  if (_activeTab == 'watermark' || _watermarkText.isNotEmpty)
                    Align(
                      alignment: _watermarkAlignment,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          _watermarkText,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _watermarkColor.withValues(alpha: _watermarkOpacity),
                          ),
                        ),
                      ),
                    ),
                  // Arrows
                  if (_currentIndex > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white, size: 40), onPressed: _prevImage),
                    ),
                  if (_currentIndex < _images.length - 1)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white, size: 40), onPressed: _nextImage),
                    ),
                ],
              ),
            ),
          ),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_activeTab == 'filters') _buildFilters(),
          if (_activeTab == 'crop') _buildCropRotate(),
          if (_activeTab == 'watermark') _buildWatermarkTools(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _tabBtn('filters', "Filters", LucideIcons.palette),
              _tabBtn('crop', "Crop", LucideIcons.crop),
              _tabBtn('watermark', "Watermark", LucideIcons.stamp),
            ],
          )
        ],
      ),
    );
  }

  Widget _tabBtn(String id, String label, IconData icon) {
    bool active = _activeTab == id;
    return InkWell(
      onTap: () => setState(() => _activeTab = id),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: active ? Theme.of(context).primaryColor : Colors.grey),
            Text(label, style: TextStyle(color: active ? Theme.of(context).primaryColor : Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCropRotate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _rotations[_currentIndex] = (_rotations[_currentIndex] - 1) % 4;
              });
            },
            icon: const Icon(LucideIcons.rotateCcw),
            label: const Text("Rotate Left"),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _rotations[_currentIndex] = (_rotations[_currentIndex] + 1) % 4;
              });
            },
            icon: const Icon(LucideIcons.rotateCw),
            label: const Text("Rotate Right"),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      {'name': 'Normal', 'matrix': _Filters.normal},
      {'name': 'Warm', 'matrix': _Filters.warm},
      {'name': 'Cool', 'matrix': _Filters.cool},
      {'name': 'Vivid', 'matrix': _Filters.vivid},
      {'name': 'B&W', 'matrix': _Filters.bw},
      {'name': 'Food', 'matrix': _Filters.food},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (ctx, i) {
          final m = filters[i]['matrix'] as List<double>;
          return GestureDetector(
            onTap: () {
              setState(() => _colorMatrices[_currentIndex] = m);
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: _colorMatrices[_currentIndex] == m 
                        ? Border.all(color: Theme.of(context).primaryColor, width: 2) 
                        : null,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(m),
                        child: Image.file(_images[_currentIndex], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(filters[i]['name'] as String, style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWatermarkTools() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: "Text", border: OutlineInputBorder()),
            onChanged: (v) => setState(() => _watermarkText = v),
          ),
          Slider(value: _watermarkOpacity, min: 0.1, max: 1.0, onChanged: (v) => setState(()=>_watermarkOpacity=v)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: const Icon(Icons.align_vertical_top), onPressed: () => setState(()=>_watermarkAlignment=Alignment.topCenter)),
              IconButton(icon: const Icon(Icons.align_horizontal_center), onPressed: () => setState(()=>_watermarkAlignment=Alignment.center)),
              IconButton(icon: const Icon(Icons.align_vertical_bottom), onPressed: () => setState(()=>_watermarkAlignment=Alignment.bottomCenter)),
            ],
          )
        ],
      ),
    );
  }
}

class _Filters {
  static const List<double> normal = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  static const List<double> bw = [
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ];

  static const List<double> vivid = [
    1.2, -0.1, -0.1, 0, 10,
    -0.1, 1.2, -0.1, 0, 10,
    -0.1, -0.1, 1.2, 0, 10,
    0,    0,    0,   1, 0,
  ];

  static const List<double> warm = [
    1.1, 0, 0, 0, 10,
    0, 1.0, 0, 0, 0,
    0, 0, 0.9, 0, -10,
    0, 0, 0, 1, 0,
  ];

  static const List<double> cool = [
    0.9, 0, 0, 0, -10,
    0, 1.0, 0, 0, 0,
    0, 0, 1.1, 0, 10,
    0, 0, 0, 1, 0,
  ];

  static const List<double> food = [
    1.1, 0.1, 0, 0, 15,
    0, 1.1, 0, 0, 10,
    0, 0, 0.9, 0, -5,
    0, 0, 0, 1, 0,
  ];
}
