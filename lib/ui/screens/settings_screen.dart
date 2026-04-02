import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../services/storage_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final colors = AppTheme.getColors(settings.themeMode);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionHeader(context, "APPEARANCE"),
          const SizedBox(height: 12),
          _buildThemeGrid(context, ref, settings.themeMode, colors),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text("Background Particle Glow"),
            subtitle: const Text("Toggles gaussian blur on background effect"),
            value: settings.showParticleGlow,
            onChanged: (val) => ref.read(settingsProvider.notifier).setParticleGlow(val),
          ),
          const SizedBox(height: 24),

          // ── FONT ──
          _sectionHeader(context, "TYPOGRAPHY"),
          const SizedBox(height: 12),
          _buildFontSelector(context, ref, settings),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text("Bold Fonts"),
            value: settings.isBoldFont,
            onChanged: (val) => ref.read(settingsProvider.notifier).setFontSettings(isBold: val),
          ),
          const SizedBox(height: 24),

          // ── INTERACTION ──
          _sectionHeader(context, "INTERACTION"),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.sparkles, color: Theme.of(context).iconTheme.color),
                    const SizedBox(width: 16),
                    Text("Animation Intensity", style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text("Low")),
                    ButtonSegment(value: 1, label: Text("Med")),
                    ButtonSegment(value: 2, label: Text("High")),
                  ],
                  selected: {settings.animationIntensity},
                  onSelectionChanged: (val) => ref.read(settingsProvider.notifier).setAnimationIntensity(val.first),
                ),
              ],
            ),
          ),
          SwitchListTile(
            secondary: const Icon(LucideIcons.vibrate),
            title: const Text("Haptic Feedback"),
            value: settings.hapticEnabled,
            onChanged: (val) => ref.read(settingsProvider.notifier).setHapticEnabled(val),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.layoutGrid, color: Theme.of(context).iconTheme.color),
                    const SizedBox(width: 16),
                    Text("UI Density", style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text("Compact")),
                    ButtonSegment(value: 1, label: Text("Comfort")),
                  ],
                  selected: {settings.uiDensity},
                  onSelectionChanged: (val) => ref.read(settingsProvider.notifier).setUiDensity(val.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── USER ──
          _sectionHeader(context, "USER"),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(LucideIcons.user),
            title: const Text("Name"),
            subtitle: Text(settings.userName.isEmpty ? "Not set" : settings.userName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(LucideIcons.edit2), onPressed: () => _editName(context, ref)),
                IconButton(icon: const Icon(LucideIcons.trash), onPressed: () => ref.read(settingsProvider.notifier).removeUserName()),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── STORAGE ──
          _sectionHeader(context, "STORAGE & DATA"),
          const SizedBox(height: 12),
          FutureBuilder<String>(
            future: StorageService.getAppStoragePath(),
            builder: (ctx, snap) {
              return ListTile(
                leading: const Icon(LucideIcons.folderOpen),
                title: const Text("Storage Path"),
                subtitle: Text(snap.data ?? "Loading..."),
              );
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.trash2, color: Colors.orange),
            title: const Text("Clear App Data"),
            subtitle: const Text("Removes cached files and processing history"),
            onTap: () => _confirmClearData(context, ref),
          ),
          ListTile(
            leading: const Icon(LucideIcons.refreshCw, color: Colors.red),
            title: const Text("Reset All Settings"),
            subtitle: const Text("Returns all settings to defaults"),
            onTap: () => _confirmReset(context, ref),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(title, style: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 12,
      letterSpacing: 1.2,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
    ));
  }

  Widget _buildThemeGrid(BuildContext context, WidgetRef ref, AppThemeMode current, LayeredColors activeColors) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: AppThemeMode.values.length,
      itemBuilder: (ctx, i) {
        final mode = AppThemeMode.values[i];
        final colors = AppTheme.getColors(mode);
        final isSelected = current == mode;
        return GestureDetector(
          onTap: () => ref.read(settingsProvider.notifier).setThemeMode(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? colors.accent : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: colors.accent.withValues(alpha: 0.3), blurRadius: 8)]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: colors.accent),
                ),
                const SizedBox(height: 6),
                Text(
                  AppTheme.themeName(mode),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9, color: colors.textPrimary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFontSelector(BuildContext context, WidgetRef ref, SettingsState settings) {
    return ListTile(
      leading: const Icon(LucideIcons.type),
      title: const Text("Font Family"),
      subtitle: Text(AppTheme.availableFonts.firstWhere((f) => f['id'] == settings.fontFamily, orElse: () => {'name': 'Inter'})['name']!),
      trailing: const Icon(LucideIcons.chevronDown),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (ctx) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.85,
              expand: false,
              builder: (ctx, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 16),
                      Text("Select Font", style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: AppTheme.availableFonts.length,
                          itemBuilder: (ctx, i) {
                            final font = AppTheme.availableFonts[i];
                            final isActive = settings.fontFamily == font['id'];
                            return ListTile(
                              leading: isActive ? Icon(LucideIcons.check, color: Theme.of(context).primaryColor) : const SizedBox(width: 24),
                              title: Text(font['name']!, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                              subtitle: Text("The quick brown fox jumps over the lazy dog", style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                              onTap: () {
                                ref.read(settingsProvider.notifier).setFontFamily(font['id']!);
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _editName(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Enter your name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).saveUserProfile(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear App Data?"),
        content: const Text("This will remove all cached files and processing history. Your name and theme preference will be preserved."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              ref.read(settingsProvider.notifier).clearAppData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("App data cleared")));
            },
            child: const Text("Clear"),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reset All Settings?"),
        content: const Text("All preferences will be restored to their defaults. This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              ref.read(settingsProvider.notifier).resetSettings();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Settings reset to defaults")));
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }
}
