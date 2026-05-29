import 'package:flutter/material.dart';

import 'package:drift/views/home_view.dart';
import 'package:drift/widgets/background_pattern.dart';
import 'package:drift/widgets/faq_tile.dart';

import '../widgets/custom_navbar.dart';

class DemoView extends StatelessWidget {
  const DemoView({super.key});

  @override
  Widget build(BuildContext context) {
    final navy = Theme.of(context).colorScheme.onSurface;
    final slate = Theme.of(context).colorScheme.onSurfaceVariant;

    Widget tierLabel(String label) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: slate,
          ),
        ),
      );
    }

    Widget arrowRow({required int count}) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: const Icon(Icons.arrow_upward, size: 20, color: Colors.grey),
          ),
        ),
      );
    }

    Widget toolCard({required String asset, required String name}) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(asset, height: 28),
            const SizedBox(height: 12),
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: navy,
              ),
            ),
          ],
        ),
      );
    }

    Widget metricCard(String title) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: navy,
            ),
          ),
        ),
      );
    }

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
      body: PatternedBackground(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 80),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          'Your tools are talking past each other. Let\'s fix that.',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Drift continuously monitors your cross-tool workflows—mapping open GitHub PRs, pending Slack mentions, and active Linear tasks to eliminate hidden attention debt automatically.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 200),
                          child: FilledButton(
                            style: ButtonStyle(
                              fixedSize: WidgetStateProperty.all(
                                const Size.fromHeight(40),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeView(),
                                ),
                              );
                            },
                            child: const Text('Get Started'),
                          ),
                        ),
                        const SizedBox(height: 80),
                        Text(
                          'How it works',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: 860,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                tierLabel('Interfaces & Agents'),
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Drift Dashboard',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: navy,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Calculates & Resolves Attention Debt',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: slate,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                                arrowRow(count: 3),
                                const SizedBox(height: 28),
                                tierLabel('Enterprise Context Layer'),
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF3B82F6,
                                    ).withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF3B82F6,
                                      ).withValues(alpha: 0.25),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Coral Context Engine',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: navy,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: metricCard('Event Graph'),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: metricCard('Metadata'),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: metricCard('Lineage'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                                arrowRow(count: 4),
                                const SizedBox(height: 28),
                                tierLabel('Business Systems'),
                                Row(
                                  children: [
                                    Expanded(
                                      child: toolCard(
                                        asset: 'assets/github_logo.png',
                                        name: 'GitHub',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: toolCard(
                                        asset: 'assets/slack_logo.png',
                                        name: 'Slack',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: toolCard(
                                        asset: 'assets/linear_logo.png',
                                        name: 'Linear',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: toolCard(
                                        asset: 'assets/notion_logo.png',
                                        name: 'Notion',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                        Text(
                          'FAQs',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Frequently asked questions',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        const Column(
                          children: [
                            FAQTile(
                              question: 'What is Coral?',
                              answer:
                                  'Coral serves as the foundational context management layer, unifying and standardizing raw real-time event updates from disparate developer tools into actionable team metrics.',
                            ),
                            FAQTile(
                              question: 'What is Drift?',
                              answer:
                                  'Drift is an automation and attention debt visibility engine built on top of Coral. It flags cross-tool contradictions, calculates context blockages, and highlights stuck items across platforms.',
                            ),
                            FAQTile(
                              question: 'What is Attention Debt?',
                              answer:
                                  'Attention debt accumulates when cross-tool tasks get stranded—such as code reviews left waiting in GitHub or action items discussed in Slack that haven\'t been tracked in Linear.',
                            ),
                            FAQTile(
                              question:
                                  'How does Drift find tool contradictions?',
                              answer:
                                  'Drift reads background metadata from your integrated platforms to flag mismatches, like a task marked \'Done\' in Linear while its corresponding GitHub PR is still open and unmerged.',
                            ),
                            FAQTile(
                              question:
                                  'Does this require complex local installation?',
                              answer:
                                  'Not at all. The interface operates completely as a lightweight web app reading structured JSON data contracts generated by a lightweight background agent.',
                            ),
                            FAQTile(
                              question:
                                  'How frequent are the synchronization cycles?',
                              answer:
                                  'Synchronization runs dynamically via background daemon processes, ensuring your dashboard metrics refresh instantly as work updates across tools.',
                            ),
                            FAQTile(
                              question:
                                  'Which platforms are supported by the Coral ecosystem?',
                              answer:
                                  'Currently, the platform fully supports deep bidirectional context tracking for GitHub, Linear, Slack, and Notion.',
                            ),
                            FAQTile(
                              question:
                                  'How does the Attention Debt Score get calculated?',
                              answer:
                                  'The score aggregates unaddressed cross-tool items weighted by their stagnation delta time, providing a tangible metric where positive numbers indicate an increasing bottleneck.',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
