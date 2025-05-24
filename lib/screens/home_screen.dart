import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import '../widgets/map_widget.dart';
import 'settings_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BluetoothService _btService = BluetoothService();
  double currentX = 0.0;
  double currentY = 0.0;
  StreamSubscription<Map<String, double>>? _subscription;

  @override
  void initState() {
    super.initState();
    _btService.startListening();
    _subscription = _btService.positionStream.listen((pos) {
      setState(() {
        currentX = pos['x']!;
        currentY = pos['y']!;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _btService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Real-time Position Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: MapWidget(currentX: currentX, currentY: currentY),
    );
  }
}
