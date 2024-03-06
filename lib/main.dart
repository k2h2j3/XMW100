import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  void _requestLocationPermission() async {
    var status = await Permission.location.request();
    if(status.isGranted) {
      _startScan();
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Location Permission Required'),
            content: Text('This app requires location permission to scan for BLE devices'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
              ),
            ],
          ),
      );
    }
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
    setState(() {
      _isScanning = true; // 스캔 중인 상태로 설정
    });
  }

  void _stopScan() {
    _scanSubscription?.cancel();
    setState(() {
      _discoveredDevices.clear(); // 초기화
      _isScanning = false; // 스캔 중이 아닌 상태로 설정
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Scanner'),
      ),
      body: _buildDeviceList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _isScanning ? _stopScan : _startScan,
        child: Icon(_isScanning ? Icons.stop : Icons.play_arrow),
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






