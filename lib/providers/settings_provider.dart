import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class SettingsState {
  final AppThemeMode themeMode;
  final String fontFamily;
  final bool isBoldFont;
  final String userName;
  final bool hasCompletedSetup;
  final int animationIntensity;  // 0=low, 1=medium, 2=high
  final bool hapticEnabled;
  final int uiDensity;  // 0=compact, 1=comfortable
  final bool showParticleGlow;

  SettingsState({
    this.themeMode = AppThemeMode.slateSand,
    this.fontFamily = 'inter',
    this.isBoldFont = false,
    this.userName = '',
    this.hasCompletedSetup = false,
    this.animationIntensity = 2,
    this.hapticEnabled = true,
    this.uiDensity = 1,
    this.showParticleGlow = true,
  });

  // Legacy compat
  bool get useInterFont => fontFamily == 'inter';

  SettingsState copyWith({
    AppThemeMode? themeMode,
    String? fontFamily,
    bool? isBoldFont,
    String? userName,
    bool? hasCompletedSetup,
    int? animationIntensity,
    bool? hapticEnabled,
    int? uiDensity,
    bool? showParticleGlow,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      fontFamily: fontFamily ?? this.fontFamily,
      isBoldFont: isBoldFont ?? this.isBoldFont,
      userName: userName ?? this.userName,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
      animationIntensity: animationIntensity ?? this.animationIntensity,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      uiDensity: uiDensity ?? this.uiDensity,
      showParticleGlow: showParticleGlow ?? this.showParticleGlow,
    );
  }

  /// Animation duration multiplier based on intensity setting
  double get animDurationMultiplier {
    switch (animationIntensity) {
      case 0: return 0.5;
      case 2: return 1.5;
      default: return 1.0;
    }
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    final fontFamily = prefs.getString('fontFamily') ?? 'inter';
    final isBold = prefs.getBool('isBoldFont') ?? false;
    final userName = prefs.getString('userName') ?? '';
    final setup = prefs.getBool('hasCompletedSetup') ?? false;
    final animIntensity = prefs.getInt('animationIntensity') ?? 2;
    final haptic = prefs.getBool('hapticEnabled') ?? true;
    final density = prefs.getInt('uiDensity') ?? 1;
    final particleGlow = prefs.getBool('showParticleGlow') ?? true;

    return SettingsState(
      themeMode: AppThemeMode.values.length > themeIndex
          ? AppThemeMode.values[themeIndex]
          : AppThemeMode.slateSand,
      fontFamily: fontFamily,
      isBoldFont: isBold,
      userName: userName,
      hasCompletedSetup: setup,
      animationIntensity: animIntensity,
      hapticEnabled: haptic,
      uiDensity: density,
      showParticleGlow: particleGlow,
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt('themeMode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setFontFamily(String family) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('fontFamily', family);
    state = state.copyWith(fontFamily: family);
  }

  Future<void> setFontSettings({bool? isBold}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (isBold != null) await prefs.setBool('isBoldFont', isBold);

    state = state.copyWith(
      isBoldFont: isBold ?? state.isBoldFont,
    );
  }

  Future<void> setAnimationIntensity(int intensity) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt('animationIntensity', intensity);
    state = state.copyWith(animationIntensity: intensity);
  }

  Future<void> setHapticEnabled(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('hapticEnabled', enabled);
    state = state.copyWith(hapticEnabled: enabled);
  }

  Future<void> setUiDensity(int density) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt('uiDensity', density);
    state = state.copyWith(uiDensity: density);
  }

  Future<void> setParticleGlow(bool show) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('showParticleGlow', show);
    state = state.copyWith(showParticleGlow: show);
  }

  Future<void> saveUserProfile(String name) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('userName', name);
    await prefs.setBool('hasCompletedSetup', true);
    state = state.copyWith(userName: name, hasCompletedSetup: true);
  }

  Future<void> removeUserName() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove('userName');
    state = state.copyWith(userName: '');
  }

  Future<void> resetSettings() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.clear();
    state = SettingsState();
  }

  Future<void> clearAppData() async {
    final prefs = ref.read(sharedPreferencesProvider);
    // Keep setup state, only clear processing caches
    final name = state.userName;
    await prefs.clear();
    // Re-persist identity
    await prefs.setString('userName', name);
    await prefs.setBool('hasCompletedSetup', true);
    state = SettingsState(userName: name, hasCompletedSetup: true);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});