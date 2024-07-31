import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:waterbottle/services/communication_handler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:collection/collection.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avatar_glow/avatar_glow.dart';

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: !isConnected
                  ? OutlinedButton(
                      onPressed: () {
                        isScanStarted ? stopScan() : startScan();
                      },
                      child: Text(isScanStarted ? "Stop Scan" : "Start Scan"),
                    )
                  : const SizedBox(),
            ),
            // SizedBox(
            //   height: 400,
            //   child: ListView.builder(
            //       padding: const EdgeInsets.all(10),
            //       itemCount: discoveredDevices.length,
            //       itemBuilder: (BuildContext context, int index) {
            //         return Padding(
            //           padding: const EdgeInsets.all(5),
            //           child: SizedBox(
            //             height: 40,
            //             child: Center(
            //                 child: OutlinedButton(
            //               child: Text(discoveredDevices[index].name),
            //               onPressed: () {
            //                 DiscoveredDevice selectedDevice =
            //                     discoveredDevices[index];
            //                 connectToDevice(selectedDevice);
            //               },
            //             )),
            //           ),
            //         );
            //       }),
            // ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
                connectedDeviceDetails,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            isConnected
                ? AvatarGlow(
                    glowColor: Colors.blue,
                    child: const Material(
                        shape: CircleBorder(),
                        child: Icon(
                          size: 70,
                          color: Colors.blue,
                          Icons.bluetooth,
                        )),
                  )
                : const Icon(
                    size: 70,
                    color: Colors.grey,
                    Icons.bluetooth,
                  ),
          ],
        ));
  }

  Future<void> connected() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('connected') ?? false) {
      setState(() {
        connectedDeviceDetails = "Connected\nto your device";
        isConnected = false;
      });
    } else {
      setState(() {
        connectedDeviceDetails = "Disconnected\nfrom your device";
        isConnected = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkPermissions();
    initNotifications();
    communicationHandler =
        CommunicationHandler(onMessageReceived: showNotification);
    connected();
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
        if (scanDevice.name == "ESP32_BLE") {
          connectToDevice(scanDevice);
        }
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
        connectedDeviceDetails = "Connected\nto your device";
      } else {
        connectedDeviceDetails = "Disconnected\nfrom your device";
      }
      setState(() {
        connectedDeviceDetails;
      });
    });
  }
}
