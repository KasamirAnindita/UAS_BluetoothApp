import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth App',
      home: BluetoothScreen(),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  void _requestPermissions() async {
    if (await Permission.location.request().isGranted) {
      _startScan();
    } else {
      // Handle permission denied
    }
  }

  void _startScan() {
    setState(() {
      isScanning = true;
    });
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      setState(() {
        devices = results.map((r) => r.device).toList();
        isScanning = false;
      });
    });
  }

  void _refresh() {
    setState(() {
      devices = [];
    });
    _startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Devices'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: isScanning
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (BuildContext context, int index) {
                BluetoothDevice device = devices[index];
                return ListTile(
                  title: Text(
                      device.name.isNotEmpty ? device.name : "Unknown Device"),
                  subtitle: Text(device.id.toString()),
                );
              },
            ),
    );
  }
}
