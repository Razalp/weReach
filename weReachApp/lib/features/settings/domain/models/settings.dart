import 'package:isar/isar.dart';

part 'settings.g.dart';

@collection
class AppSettings {
  Id id = 0; // Fixed ID of 0 for single configuration instance

  bool vibrationEnabled = true;

  bool soundEnabled = true;

  double alertRadius = 1.0; // default 1 km before destination

  String alarmSound = "default"; // "default", "beep", "railway"

  // Temporary storage of last destination details
  String? lastDestinationName;
  double? lastDestinationLatitude;
  double? lastDestinationLongitude;

  AppSettings();
}
