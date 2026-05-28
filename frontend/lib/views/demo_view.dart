import 'package:flutter/material.dart';

class DemoView extends StatelessWidget {
  const DemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo View'),
      ),
      body: const Center(
        child: Text('Demo View Content'),
      ),
    );
  }
}