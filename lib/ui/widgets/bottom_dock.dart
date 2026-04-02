import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BottomDock extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomDock({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          // Fluid moving indicator using AnimatedAlign
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            // Math: Map index [0, 1] to [-1.0, 1.0].
            // If more items, it would be: -1.0 + (currentIndex * (2.0 / (itemCount - 1)))
            alignment: Alignment(currentIndex == 0 ? -1.0 : 1.0, 0.0),
            child: FractionallySizedBox(
              widthFactor: 0.5, // since 2 items
              child: Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ),
          
          Row(
            children: [
              _buildItem(context, 0, "PDF", LucideIcons.fileText),
              _buildItem(context, 1, "Images", LucideIcons.image),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, String label, IconData icon) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  size: isSelected ? 28 : 24,
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
