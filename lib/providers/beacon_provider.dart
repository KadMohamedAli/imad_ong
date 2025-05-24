import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/beacon.dart';

class BeaconProvider with ChangeNotifier {
  final Map<String, Beacon> _beacons = {};

  static const String storageKey = 'beacons';

  BeaconProvider() {
    _loadFromPrefs();
  }

  Beacon getBeacon(String id) => _beacons[id]!;

  Map<String, Beacon> get beacons => _beacons;

  void updateBeacon(String id, double x, double y) {
    _beacons[id] = Beacon(id: id, x: x, y: y);
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(storageKey);

    if (jsonString != null) {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      _beacons.clear();
      decoded.forEach((key, value) {
        _beacons[key] = Beacon(id: value['id'], x: value['x'], y: value['y']);
      });
      notifyListeners();
    } else {
      // Initialize with default beacons if nothing stored yet
      _beacons.addAll({
        'b1': Beacon(id: 'b1', x: 0.0, y: 0.0),
        'b2': Beacon(id: 'b2', x: 10.0, y: 0.0),
        'b3': Beacon(id: 'b3', x: 5.0, y: 10.0),
      });
      _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Convert _beacons to a Map<String, Map<String, dynamic>> for JSON encoding
    final Map<String, dynamic> jsonMap = _beacons.map(
      (key, beacon) =>
          MapEntry(key, {'id': beacon.id, 'x': beacon.x, 'y': beacon.y}),
    );

    final jsonString = json.encode(jsonMap);
    await prefs.setString(storageKey, jsonString);
  }
}
