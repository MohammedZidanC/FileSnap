import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';
import '../screens/legal_screen.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: Theme.of(context).cardColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.image, 
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "FileSnap",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _buildMenuItem(context, LucideIcons.settings, "Settings", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }),
            _buildMenuItem(context, LucideIcons.info, "About", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
            }),
            _buildMenuItem(context, LucideIcons.shield, "Privacy", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen(title: "Privacy Policy")));
            }),
            _buildMenuItem(context, LucideIcons.fileText, "Terms", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen(title: "Terms of Service")));
            }),
            const Spacer(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  return Text(
                    "Version ${snapshot.data?.version ?? '1.0.0'} (${snapshot.data?.buildNumber ?? '1'})",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
