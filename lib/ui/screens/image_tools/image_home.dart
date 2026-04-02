import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/tool_card.dart';
import 'compress_tool.dart';
import 'convert_tool.dart';
import 'resize_tool.dart';
import 'crop_tool.dart';
import 'watermark_tool.dart';

class ImageHome extends StatelessWidget {
  const ImageHome({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = <Widget>[
      ToolCard(
        title: "Resize Image",
        icon: LucideIcons.minimize,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResizeToolScreen())),
      ),
      ToolCard(
        title: "Compress",
        icon: LucideIcons.shrink,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompressToolScreen())),
      ),
      ToolCard(
        title: "Convert",
        icon: LucideIcons.refreshCw,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConvertToolScreen())),
      ),
      ToolCard(
        title: "Crop & Adjust",
        icon: LucideIcons.crop,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CropToolScreen())),
      ),
      ToolCard(
        title: "Watermark",
        icon: LucideIcons.stamp,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WatermarkToolScreen())),
      ),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            "Image Tools",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.8),
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05),
          const SizedBox(height: 16),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: tools.length,
            itemBuilder: (context, index) {
              return tools[index]
                  .animate()
                  .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * index))
                  .slideY(begin: 0.1, duration: 300.ms, delay: Duration(milliseconds: 50 * index));
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
