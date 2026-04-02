import 'package:flutter/material.dart';

class ProcessingScreen extends StatefulWidget {
  final double progress; // 0.0 to 1.0

  const ProcessingScreen({super.key, required this.progress});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bubbleController;

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Processing...",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Text(
            "${(widget.progress * 100).toInt()}%",
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Container(
              height: 24, // thick progress bar
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        // The filled portion
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: constraints.maxWidth * widget.progress,
                          height: constraints.maxHeight,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // The bubbles active only inside filled portion
                        Positioned.fill(
                          child: ClipRect(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              widthFactor: widget.progress,
                              child: AnimatedBuilder(
                                animation: _bubbleController,
                                builder: (context, child) {
                                  // Simple sliding diagonal stripes substituting for bubbles
                                  // to ensure high performance without memory bloat
                                  return ShaderMask(
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        colors: [
                                          Colors.white.withValues(alpha: 0.1),
                                          Colors.white.withValues(alpha: 0.0),
                                        ],
                                        begin: Alignment.bottomLeft,
                                        end: Alignment.topRight,
                                        stops: const [0.0, 1.0],
                                        transform: GradientRotation(_bubbleController.value * 2 * 3.14),
                                      ).createShader(bounds);
                                    },
                                    child: Container(
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
