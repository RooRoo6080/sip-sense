import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:waterbottle/bluetooth/communication_handler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:collection/collection.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({Key? key}) : super(key: key);

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  SimpleLogger logger = SimpleLogger();
  CommunicationHandler? communicationHandler;
  bool isScanStarted = false;
  bool isConnected = false;
  List<DiscoveredDevice> discoveredDevices =
      List<DiscoveredDevice>.empty(growable: true);
  String connectedDeviceDetails = "";

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Connect"),
        ),
        body: Column(
          children: [
            Center(
              child: TextButton(
                onPressed: () {
                  isScanStarted ? stopScan() : startScan();
                },
                child: Text(isScanStarted ? "Stop Scan" : "Start Scan"),
              ),
            ),
            SizedBox(
              height: 400,
              child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: discoveredDevices.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(5),
                      child: SizedBox(
                        height: 40,
                        child: Center(
                            child: OutlinedButton(
                          child: Text(discoveredDevices[index].name),
                          onPressed: () {
                            DiscoveredDevice selectedDevice =
                                discoveredDevices[index];
                            connectToDevice(selectedDevice);
                          },
                        )),
                      ),
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(connectedDeviceDetails),
            )
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    checkPermissions();
    initNotifications();
    communicationHandler =
        CommunicationHandler(onMessageReceived: showNotification);
    if (communicationHandler?.isConnected ?? false) {
      setState(() {
        isConnected = true;
        connectedDeviceDetails =
            "Connected Device Details\n\n${communicationHandler?.getConnectedDevice()}";
      });
    }
  }

  void checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.bluetoothAdvertise,
    ].request();

    logger.info("PermissionStatus -- $statuses");
  }

  void initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New BLE Message',
      message,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void startScan() {
    communicationHandler ??=
        CommunicationHandler(onMessageReceived: showNotification);
    communicationHandler?.startScan((scanDevice) {
      logger.info("Scan device: ${scanDevice.name}");
      if (discoveredDevices
              .firstWhereOrNull((val) => val.id == scanDevice.id) ==
          null) {
        logger.info("Added new device to list: ${scanDevice.name}");
        setState(() {
          discoveredDevices.add(scanDevice);
        });
      }
    });

    setState(() {
      isScanStarted = true;
      discoveredDevices.clear();
    });
  }

  Future<void> stopScan() async {
    await communicationHandler?.stopScan();
    setState(() {
      isScanStarted = false;
    });
  }

  Future<void> connectToDevice(DiscoveredDevice selectedDevice) async {
    await stopScan();
    communicationHandler?.connectToDevice(selectedDevice, (isConnected) {
      this.isConnected = isConnected;
      if (isConnected) {
        connectedDeviceDetails = "Connected Device Details\n\n$selectedDevice";
      } else {
        connectedDeviceDetails = "";
      }
      setState(() {
        connectedDeviceDetails;
      });
    });
  }
}
