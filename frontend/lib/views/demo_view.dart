import 'package:flutter/material.dart';
import 'package:frontend/views/home_view.dart';
import 'package:frontend/widgets/background_pattern.dart';
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
                              fixedSize: WidgetStateProperty.all(const Size.fromHeight(40)),
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
                        const SizedBox(height: 100),
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
                        Column(
                          children: [
                            ExpansionTile(
                              title: Text(
                                'What is Coral?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    'Coral serves as the foundational context management layer, unifying and standardizing raw real-time event updates from disparate developer tools into actionable team metrics.',
                                    style: TextStyle(color: Color(0xFF64748B)),
                                  ),
                                ),
                              ],
                            ),
                            ExpansionTile(
                              title: Text(
                                'What is Drift?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    'Drift is an automation and attention debt visibility engine built on top of Coral. It flags cross-tool contradictions, calculates context blockages, and highlights stuck items across platforms.',
                                    style: TextStyle(color: Color(0xFF64748B)),
                                  ),
                                ),
                              ],
                            ),
                            ExpansionTile(
                              title: Text(
                                'What is Attention Debt?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    'Attention debt accumulates when cross-tool tasks get stranded—such as code reviews left waiting in GitHub or action items discussed in Slack that haven\'t been tracked in Linear.',
                                    style: TextStyle(color: Color(0xFF64748B)),
                                  ),
                                ),
                              ],
                            ),
                            ExpansionTile(
                              title: Text(
                                'How does Drift find tool contradictions?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    'Drift reads background metadata from your integrated platforms to flag mismatches, like a task marked \'Done\' in Linear while its corresponding GitHub PR is still open and unmerged.',
                                    style: TextStyle(color: Color(0xFF64748B)),
                                  ),
                                ),
                              ],
                            ),
                            ExpansionTile(
                              title: Text(
                                'Does this require complex local installation?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    'Not at all. The interface operates completely as a lightweight web app reading structured JSON data contracts generated by a lightweight background agent.',
                                    style: TextStyle(color: Color(0xFF64748B)),
                                  ),
                                ),
                              ],
                            ),
                            ExpansionTile(
                              title: Text(
                                'How frequent are the synchronization cycles?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    'Synchronization runs dynamically via background daemon processes, ensuring your dashboard metrics refresh instantly as work updates across tools.',
                                    style: TextStyle(color: Color(0xFF64748B)),
                                  ),
                                ),
                              ],
                            ),
                            ExpansionTile(
                              title: Text(
                                'Which platforms are supported by the Coral ecosystem?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    'Currently, the platform fully supports deep bidirectional context tracking for GitHub, Linear, Slack, and Notion.',
                                    style: TextStyle(color: Color(0xFF64748B)),
                                  ),
                                ),
                              ],
                            ),
                            ExpansionTile(
                              title: Text(
                                'How does the Attention Debt Score get calculated?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    'The score aggregates unaddressed cross-tool items weighted by their stagnation delta time, providing a tangible metric where positive numbers indicate an increasing bottleneck.',
                                    style: TextStyle(color: Color(0xFF64748B)),
                                  ),
                                ),
                              ],
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
