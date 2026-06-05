import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/settings.dart';
import '../../../../core/providers/core_providers.dart';

class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final Ref _ref;

  SettingsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final isar = _ref.read(isarServiceProvider);
      final settings = await isar.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSettings({
    bool? vibrationEnabled,
    bool? soundEnabled,
    double? alertRadius,
    String? alarmSound,
    String? lastDestinationName,
    double? lastDestinationLatitude,
    double? lastDestinationLongitude,
  }) async {
    final current = state.value;
    if (current == null) return;

    final updated = AppSettings()
      ..id = current.id
      ..vibrationEnabled = vibrationEnabled ?? current.vibrationEnabled
      ..soundEnabled = soundEnabled ?? current.soundEnabled
      ..alertRadius = alertRadius ?? current.alertRadius
      ..alarmSound = alarmSound ?? current.alarmSound
      ..lastDestinationName = lastDestinationName ?? current.lastDestinationName
      ..lastDestinationLatitude = lastDestinationLatitude ?? current.lastDestinationLatitude
      ..lastDestinationLongitude = lastDestinationLongitude ?? current.lastDestinationLongitude;

    try {
      final isar = _ref.read(isarServiceProvider);
      await isar.saveSettings(updated);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
  return SettingsNotifier(ref);
});
