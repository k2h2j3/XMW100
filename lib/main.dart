import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScannerPage(),
    );
  }
}

class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final _ble = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  List<DiscoveredDevice> _discoveredDevices = [];

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }

  void _startScan() {
    _scanSubscription = _ble.scanForDevices(withServices: []).listen(
          (device) {
        setState(() {
          _discoveredDevices.add(device);
        });
      },
      onError: (dynamic error) {
        print('Error : $error');
      },
    );
  }

  void _stopScan() {
    _scanSubscription?.cancel();
    _discoveredDevices.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Scanner'),
      ),
      body: _buildDeviceList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanSubscription != null ? _stopScan : _startScan,
        child: Icon(_scanSubscription != null ? Icons.stop : Icons.play_arrow),
      ),
    );
  }

  Widget _buildDeviceList() {
    return ListView.builder(
      itemCount: _discoveredDevices.length,
      itemBuilder: (context, index) {
        final device = _discoveredDevices[index];
        return ListTile(
          title: Text(device.name ?? 'Unknown'),
          subtitle: Text(device.id),
          onTap: () {
            // 연결하거나 해당 장치와 상호작용하는 작업을 수행
            print('Tapped on device: ${device.id}');
          },
        );
      },
    );
  }
}






