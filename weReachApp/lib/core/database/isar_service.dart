import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/search/domain/models/destination.dart';
import '../../features/settings/domain/models/settings.dart';

class IsarService {
  late Isar _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    
    // Check if Isar instance is already opened to avoid errors during hot reload
    if (Isar.instanceNames.isEmpty) {
      _isar = await Isar.open(
        [DestinationSchema, AppSettingsSchema],
        directory: dir.path,
      );
    } else {
      _isar = Isar.getInstance()!;
    }

    // Initialize default settings if not exists
    await _initDefaultSettings();
  }

  // Get database instance
  Isar get db => _isar;

  Future<void> _initDefaultSettings() async {
    final existing = await _isar.appSettings.get(0);
    if (existing == null) {
      final defaultSettings = AppSettings();
      await _isar.writeTxn(() async {
        await _isar.appSettings.put(defaultSettings);
      });
    }
  }

  // Settings operations
  Future<AppSettings> getSettings() async {
    return (await _isar.appSettings.get(0)) ?? AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _isar.writeTxn(() async {
      await _isar.appSettings.put(settings);
    });
  }

  // Destinations operations
  Future<List<Destination>> getRecentDestinations() async {
    return await _isar.destinations
        .filter()
        .isFavoriteEqualTo(false)
        .sortByTimestampDesc()
        .limit(10)
        .findAll();
  }

  Future<List<Destination>> getFavoriteDestinations() async {
    return await _isar.destinations
        .filter()
        .isFavoriteEqualTo(true)
        .sortByTimestampDesc()
        .findAll();
  }

  Future<void> addDestination(Destination destination) async {
    await _isar.writeTxn(() async {
      // Check if duplicate location coords exist to avoid redundancy
      final existing = await _isar.destinations
          .filter()
          .latitudeEqualTo(destination.latitude)
          .longitudeEqualTo(destination.longitude)
          .findFirst();
          
      if (existing != null) {
        existing.timestamp = DateTime.now();
        existing.isFavorite = destination.isFavorite;
        existing.name = destination.name;
        existing.address = destination.address;
        await _isar.destinations.put(existing);
      } else {
        await _isar.destinations.put(destination);
      }
    });
  }

  Future<void> toggleFavorite(int id) async {
    final dest = await _isar.destinations.get(id);
    if (dest != null) {
      await _isar.writeTxn(() async {
        dest.isFavorite = !dest.isFavorite;
        await _isar.destinations.put(dest);
      });
    }
  }

  Future<void> deleteDestination(int id) async {
    await _isar.writeTxn(() async {
      await _isar.destinations.delete(id);
    });
  }
}
