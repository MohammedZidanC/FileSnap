import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _panelController;
  late Animation<Offset> _panelSlide;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _panelSlide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _panelController, curve: Curves.easeOutBack));

    Future.delayed(const Duration(milliseconds: 100), () {
      _panelController.forward();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _panelController.dispose();
    super.dispose();
  }

  void _saveSetup() {
    if (_formKey.currentState!.validate()) {
      // Validate letters only manually or via validator
      String name = _nameController.text.trim();
      ref.read(settingsProvider.notifier).saveUserProfile(name);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _skipSetup() {
    ref.read(settingsProvider.notifier).saveUserProfile("");
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(settingsProvider).themeMode;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SlideTransition(
                  position: _panelSlide,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Welcome to FileSnap",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Let's personalize your experience.",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                ),
                          ),
                          const SizedBox(height: 32),
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: 'Your Name',
                                filled: true,
                                fillColor: Theme.of(context).scaffoldBackgroundColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Name is required.";
                                }
                                if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                                  return "Only letters are allowed.";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            "Choose Theme",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: AppThemeMode.values.map((mode) {
                              final isSelected = themeMode == mode;
                              return ChoiceChip(
                                label: Text(AppTheme.themeName(mode)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(settingsProvider.notifier).setThemeMode(mode);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Save button (capsule, bounce animation)
              GestureDetector(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) {
                  setState(() => _isPressed = false);
                  _saveSetup();
                },
                onTapCancel: () => setState(() => _isPressed = false),
                child: AnimatedScale(
                  scale: _isPressed ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30), // Capsule
                    ),
                    child: const Text(
                      "SAVE & CONTINUE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _skipSetup,
                child: Text(
                  "Skip",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
