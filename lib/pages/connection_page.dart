import 'package:flutter/material.dart';

class ConnectionPage extends StatelessWidget {
  const ConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Connection'),
      ),
      body: const Center(
        child: Text('Connect to your water bottle'),
      ),
    );
  }
}
