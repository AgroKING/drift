import 'package:flutter/material.dart';

import 'package:Drift/views/home_view.dart';
import 'package:Drift/widgets/background_pattern.dart';
import 'package:Drift/widgets/faq_tile.dart';

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
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 40,
                          runSpacing: 40,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Wrap(
                                    spacing: 20,
                                    runSpacing: 20,
                                    children: [
                                      Image.asset('assets/github_logo.png', height: 32),
                                      Image.asset('assets/slack_logo.png', height: 32),
                                      Image.asset('assets/linear_logo.png', height: 32),
                                      Image.asset('assets/notion_logo.png', height: 32),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Raw Tool Events',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_rounded, color: Colors.blue, size: 32),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Text(
                                    'Coral Engine',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Standardizes Context',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_rounded, color: Colors.blue, size: 32),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Text(
                                    'Drift Dashboard',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Calculates Attention Debt',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
