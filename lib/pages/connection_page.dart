import 'package:flutter/material.dart';

class ConnectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Connection'),
      ),
      body: Center(
        child: Text('Connect to your water bottle'),
      ),
    );
  }
}
