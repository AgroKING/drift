import 'package:flutter/material.dart';
import 'package:frontend/views/demo_view.dart';

class CustomNavBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> actions;

  const CustomNavBar({super.key, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          constraints: const BoxConstraints.expand(height: 56),
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('assets/logo.png', width: 28, height: 28),
                  const SizedBox(width: 12),
                  DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DemoView(),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        ),
                      ),
                      child: const Text(
                        'Drift',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      // const Text('Drift'),
                    ),
                  ),
                ],
              ),
              Row(children: actions),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
