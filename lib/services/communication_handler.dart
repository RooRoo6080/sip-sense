import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:waterbottle/services/ble_connection_handler.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:waterbottle/data/logs.dart';
import 'package:waterbottle/data/db.dart';

class CommunicationHandler {
  SimpleLogger logger = SimpleLogger();
  late final BleConnectionHandler bleConnectionHandler;
  late ConsumptionData _consumptionData;

  // device information
  static final Uuid characteristicId =
      Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8");
  static final Uuid serviceId =
      Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b");

  String oldMessage = "-0";

  String deviceId = "";
  bool isConnected = false;
  late Function(String) onMessageReceived;

  Future<void> _loadConsumptionData() async {
    final data = await ConsumptionData.loadConsumptionData();
    _consumptionData = data ??
        ConsumptionData(
          waterInBottle: 0,
          bottleCapacity: 24,
          consumeGoal: 35,
        );
  }

  Future<void> _updateConsumptionData() async {
    await ConsumptionData.saveConsumptionData(_consumptionData);
    _loadConsumptionData();
  }

  Future<void> _addLogEntry(double consumed) async {
    final logs = await Logs.loadLogs() ?? Logs(entries: []);
    final newEntry = LogEntry(DateTime.now(), consumed);
    logs.entries.add(newEntry);
    await Logs.saveLogs(logs);
    Logs.waterDrunk(consumed);
  }

  CommunicationHandler({required this.onMessageReceived}) {
    bleConnectionHandler = BleConnectionHandler();
  }

  void startScan(Function(DiscoveredDevice) scanDevice) {
    bleConnectionHandler.startBluetoothScan(
        (discoveredDevice) => {scanDevice(discoveredDevice)});
  }

  Future<void> stopScan() async {
    await bleConnectionHandler.stopScan();
  }

  void connectToDevice(
      DiscoveredDevice discoveredDevice, Function(bool) connectionStatus) {
    bleConnectionHandler.connectToDevice(discoveredDevice, (isConnected) {
      this.isConnected = isConnected;
      deviceId = discoveredDevice.id;
      connectionStatus(isConnected);
      if (isConnected) {
        readDeviceInformation(serviceId, characteristicId);
      }
    });
  }

  DiscoveredDevice? getConnectedDevice() {
    return isConnected ? bleConnectionHandler.getConnectedDevice() : null;
  }

  Future<void> readDeviceInformation(
      Uuid service, Uuid characteristicToRead) async {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceId,
        characteristicId: characteristicId,
        deviceId: deviceId);
    final response = await bleConnectionHandler.flutterReactiveBle
        .readCharacteristic(characteristic);
    receivedCharacteristicValue(
        characteristic: characteristic, values: response);
  }

  Future<void> subscribeToMeasurement(
      Uuid service, Uuid characteristicToNotify) async {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceId,
        characteristicId: characteristicId,
        deviceId: deviceId);
    bleConnectionHandler.flutterReactiveBle
        .subscribeToCharacteristic(characteristic)
        .listen((data) {
      if (data.isNotEmpty) {
        receivedCharacteristicValue(
            characteristic: characteristic, values: data);
      }
    }, onError: (dynamic error) {
      logger.info('Error with read measurement : $error');
    });
  }

  void receivedCharacteristicValue(
      {required QualifiedCharacteristic characteristic,
      required List<int> values}) async {
    if (characteristic.characteristicId == characteristicId) {
      String value = utf8.decode(values);
      if (oldMessage != value) {
        if (double.parse(value) == -1) {
          await _loadConsumptionData();
          _consumptionData.waterInBottle = _consumptionData.bottleCapacity;
          await _updateConsumptionData();
        }
        logger.info('Message: $value');
        _addLogEntry(double.parse(value) / 10.0);
        oldMessage = value;
      }
      // onMessageReceived(value); // notify every time data is received
      readDeviceInformation(serviceId, characteristicId);
    }
  }
}
