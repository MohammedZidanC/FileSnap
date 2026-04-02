import 'package:flutter/material.dart';
import 'bouncing_button.dart';

class ToolCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const ToolCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).primaryColor;

    return BouncingButton(
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          // Layered card: base color with inner highlight gradient
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).cardColor,
              Theme.of(context).cardColor.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accent.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            // Soft outer shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            // Subtle accent glow
            BoxShadow(
              color: accent.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: accent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
