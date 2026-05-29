import 'package:flutter/material.dart';
import 'package:frontend/views/home_view.dart';
import '../widgets/custom_navbar.dart';

class DemoView extends StatelessWidget {
  const DemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavBar(
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeView()),
              );
            },
            child: const Text('Get Started'),
          ),
        ],
      ),
      body: const Center(
        child: Text('Demo View Content'),
      ),
    );
  }
}
