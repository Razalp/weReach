import 'package:isar/isar.dart';

part 'destination.g.dart';

@collection
class Destination {
  Id id = Isar.autoIncrement;

  late String name;
  
  String? address;

  late double latitude;

  late double longitude;

  late DateTime timestamp;

  bool isFavorite = false;
  
  // Empty constructor required by Isar
  Destination();

  Destination.create({
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.isFavorite = false,
  });
}
