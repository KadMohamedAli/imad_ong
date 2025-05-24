import 'package:flutter/material.dart';
import '../models/beacon.dart';

class BeaconProvider with ChangeNotifier {
  final Map<String, Beacon> _beacons = {
    'b1': Beacon(id: 'b1', x: 0.0, y: 0.0),
    'b2': Beacon(id: 'b2', x: 10.0, y: 0.0),
    'b3': Beacon(id: 'b3', x: 5.0, y: 10.0),
  };

  Beacon getBeacon(String id) => _beacons[id]!;

  void updateBeacon(String id, double x, double y) {
    _beacons[id] = Beacon(id: id, x: x, y: y);
    notifyListeners();
  }

  Map<String, Beacon> get beacons => _beacons;
}
