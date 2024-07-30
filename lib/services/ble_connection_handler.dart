import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:waterbottle/services/notification_service.dart';

class BleConnectionHandler {
  SimpleLogger logger = SimpleLogger();

  final flutterReactiveBle = FlutterReactiveBle();
  StreamSubscription? streamSubscription;
  StreamSubscription<ConnectionStateUpdate>? connection;

  DiscoveredDevice? connectedDevice;

  BleConnectionHandler();

  void startBluetoothScan(Function(DiscoveredDevice) discoveredDevice) async {
    if (flutterReactiveBle.status == BleStatus.ready) {
      logger.info("Start ble discovery");
      streamSubscription = flutterReactiveBle.scanForDevices(withServices: []).listen((device) async {
        if (device.name.isNotEmpty) discoveredDevice(device);
      }, onError: (Object e) => logger.info('Device scan fails with error: $e'));
    } else {
      logger.info("Device is not ready for communication");
      Future.delayed(const Duration(seconds: 2), () {
        startBluetoothScan(discoveredDevice);
      });
    }
  }

  void connectToDevice(DiscoveredDevice discoveredDevice, Function(bool) connectionStatus) async {
    final prefs = await SharedPreferences.getInstance();
    connection = flutterReactiveBle.connectToDevice(id: discoveredDevice.id).listen((connectionState) async {
      logger.info("ConnectionState for device ${discoveredDevice.name} : ${connectionState.connectionState}");
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        logger.info("-------- ESP32 Connected --------");
        NotificationService().removeNotification(1);
        await prefs.setBool('connected', true);
        connectedDevice = discoveredDevice;
        connectionStatus(true);
      } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
        logger.info("-------- ESP32 Disconnected --------");
        NotificationService().showNotification(1, 'Device disconnected', 'Your water bottle is not connected');
        await prefs.setBool('connected', false);
        connectedDevice = null;
        connectionStatus(false);
      }
    }, onError: (Object error) {
      logger.info("Connecting to device resulted in error $error");
    });
  }

  DiscoveredDevice? getConnectedDevice() {
    return connectedDevice;
  }

  Future<void> closeConnection() async {
    logger.info("Close Connection");
    await streamSubscription?.cancel();
    await connection?.cancel();
    streamSubscription = null;
    connectedDevice = null;
  }

  Future<void> stopScan() async {
    logger.info("Stop ble discovery");
    await streamSubscription?.cancel();
    streamSubscription = null;
  }
}
