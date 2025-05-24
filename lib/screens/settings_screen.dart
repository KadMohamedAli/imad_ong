import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/beacon_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final beaconProvider = Provider.of<BeaconProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: ['b1', 'b2', 'b3'].map((id) {
          final beacon = beaconProvider.getBeacon(id);
          final xController = TextEditingController(text: beacon.x.toString());
          final yController = TextEditingController(text: beacon.y.toString());

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("Beacon $id"),
              subtitle: Column(
                children: [
                  TextField(
                    controller: xController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "X"),
                  ),
                  TextField(
                    controller: yController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Y"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      beaconProvider.updateBeacon(
                        id,
                        double.tryParse(xController.text) ?? beacon.x,
                        double.tryParse(yController.text) ?? beacon.y,
                      );
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
