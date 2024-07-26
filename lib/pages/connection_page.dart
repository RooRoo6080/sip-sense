import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];
  List<ScanResult> _scanResults = [];

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() {
    flutterBlue.startScan(timeout: const Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      setState(() {
        _scanResults = results;
      });
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      _connectedDevice = device;
    });
    discoverServices();
  }

  void discoverServices() async {
    if (_connectedDevice != null) {
      List<BluetoothService> services = await _connectedDevice!.discoverServices();
      setState(() {
        _services = services;
      });
    }
  }

  void disconnectFromDevice() {
    _connectedDevice?.disconnect();
    setState(() {
      _connectedDevice = null;
      _services = [];
    });
  }

  void showDeviceSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select a Device'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _scanResults.length,
            itemBuilder: (context, index) {
              ScanResult result = _scanResults[index];
              return ListTile(
                title: Text(result.device.name.isNotEmpty ? result.device.name : 'Unknown Device'),
                subtitle: Text(result.device.id.toString()),
                onTap: () {
                  Navigator.pop(context);
                  connectToDevice(result.device);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32 Connection Page'),
      ),
      body: _connectedDevice == null ? buildScanningView() : buildDeviceView(),
    );
  }

  Widget buildScanningView() {
    return Center(
      child: ElevatedButton(
        onPressed: showDeviceSelectionDialog,
        child: const Text('Select Device'),
      ),
    );
  }

  Widget buildDeviceView() {
    return Column(
      children: [
        ListTile(
          title: Text('Device: ${_connectedDevice?.name}'),
          subtitle: const Text('Status: Connected'),
          trailing: ElevatedButton(
            onPressed: disconnectFromDevice,
            child: const Text('Disconnect'),
          ),
        ),
        Expanded(
          child: ListView(
            children: _services.map((service) {
              return ListTile(
                title: Text('Service: ${service.uuid}'),
                subtitle: Text('Characteristics: ${service.characteristics.length}'),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
