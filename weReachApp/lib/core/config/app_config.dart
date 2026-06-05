import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  static late String mapboxAccessToken;
  static late String apiBaseUrl;

  static Future<void> load() async {
    final jsonStr = await rootBundle.loadString('assets/config.json');
    final Map<String, dynamic> config = json.decode(jsonStr);
    mapboxAccessToken = config['mapboxAccessToken'] ?? '';
    apiBaseUrl = config['apiBaseUrl'] ?? 'http://localhost:3000/api';
  }
}
