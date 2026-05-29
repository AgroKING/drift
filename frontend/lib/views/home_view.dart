import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavBar(actions: []),
      body: const Center(
        child: Text('Home View Content'),
      ),
    );
  }
}
