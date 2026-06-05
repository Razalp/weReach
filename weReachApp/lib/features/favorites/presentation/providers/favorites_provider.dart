import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../search/domain/models/destination.dart';

class FavoritesNotifier extends StateNotifier<AsyncValue<List<Destination>>> {
  final Ref _ref;

  FavoritesNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    state = const AsyncValue.loading();
    try {
      final isar = _ref.read(isarServiceProvider);
      final list = await isar.getFavoriteDestinations();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addFavorite(String name, String address, double lat, double lng) async {
    try {
      final isar = _ref.read(isarServiceProvider);
      final dest = Destination.create(
        name: name,
        address: address,
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        isFavorite: true,
      );
      await isar.addDestination(dest);
      await loadFavorites();
      
      // Also trigger reload of recents
      _ref.read(recentsProvider.notifier).loadRecents();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavorite(int id) async {
    try {
      final isar = _ref.read(isarServiceProvider);
      await isar.toggleFavorite(id);
      await loadFavorites();
      _ref.read(recentsProvider.notifier).loadRecents();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteFavorite(int id) async {
    try {
      final isar = _ref.read(isarServiceProvider);
      await isar.deleteDestination(id);
      await loadFavorites();
      _ref.read(recentsProvider.notifier).loadRecents();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class RecentsNotifier extends StateNotifier<AsyncValue<List<Destination>>> {
  final Ref _ref;

  RecentsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadRecents();
  }

  Future<void> loadRecents() async {
    state = const AsyncValue.loading();
    try {
      final isar = _ref.read(isarServiceProvider);
      final list = await isar.getRecentDestinations();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addRecent(String name, String address, double lat, double lng) async {
    try {
      final isar = _ref.read(isarServiceProvider);
      final dest = Destination.create(
        name: name,
        address: address,
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        isFavorite: false,
      );
      await isar.addDestination(dest);
      await loadRecents();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearRecent(int id) async {
    try {
      final isar = _ref.read(isarServiceProvider);
      await isar.deleteDestination(id);
      await loadRecents();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Global Providers
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<List<Destination>>>((ref) {
  return FavoritesNotifier(ref);
});

final recentsProvider = StateNotifierProvider<RecentsNotifier, AsyncValue<List<Destination>>>((ref) {
  return RecentsNotifier(ref);
});
