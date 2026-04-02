import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../widgets/bottom_dock.dart';
import '../widgets/side_menu.dart';
import '../widgets/dynamic_background.dart';
import 'pdf_tools/pdf_home.dart';
import 'image_tools/image_home.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const PdfHome(),
    const ImageHome(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final userName = settings.userName;
    final colors = AppTheme.getColors(settings.themeMode);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const SideMenu(),
      backgroundColor: Colors.transparent,
      body: DynamicBackground(
        colors: colors,
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.card,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(LucideIcons.menu),
                          ),
                        ),
                        Text(
                          userName.isNotEmpty ? "Hi, $userName!" : "Hello!",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 44), // balance middle
                      ],
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _pages[_currentIndex],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Dock
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: BottomDock(
                currentIndex: _currentIndex,
                onTap: (idx) {
                  setState(() => _currentIndex = idx);
                },
              ).animate().slideY(begin: 1, duration: 400.ms, curve: Curves.easeOutBack),
            ),
          ],
        ),
      ),
    );
  }
}
