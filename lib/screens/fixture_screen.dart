import 'package:flutter/material.dart';
import 'dart:math';

class FixtureScreen extends StatefulWidget {
  const FixtureScreen({super.key});

  @override
  State<FixtureScreen> createState() => _FixtureScreenState();
}

class _FixtureScreenState extends State<FixtureScreen> {
  final TextEditingController _poolCountController = TextEditingController();
  int poolCount = 0;
  List<List<TextEditingController>> teamControllers = [];
  bool fixturesGenerated = false;
  List<Map<String, dynamic>> combinedFixtures = [];

  void createTeamInputs() {
    teamControllers = List.generate(
      poolCount,
          (_) => [],
    );
  }

  void generateFixtures() {
    List<Map<String, dynamic>> allMatches = [];

    // Generate all matches pool-wise
    for (int p = 0; p < poolCount; p++) {
      List<String> teams = teamControllers[p].map((c) => c.text).toList();
      List<Map<String, String>> matches = [];

      for (int i = 0; i < teams.length; i++) {
        for (int j = i + 1; j < teams.length; j++) {
          matches.add({"team1": teams[i], "team2": teams[j]});
        }
      }

      matches.shuffle(Random());

      for (var match in matches) {
        allMatches.add({
          'team1': match['team1'],
          'team2': match['team2'],
          'pool': 'Pool ${p + 1}',
          'done': false,
          'winner': null,
        });
      }
    }

    // Group matches by pool
    Map<String, List<Map<String, dynamic>>> matchesByPool = {};
    for (var match in allMatches) {
      matchesByPool.putIfAbsent(match['pool'], () => []).add(match);
    }

    // Smart scheduling: pick matches in round-robin fashion from each pool
    List<Map<String, dynamic>> smartSchedule = [];
    Map<String, int> poolIndices = {for (var pool in matchesByPool.keys) pool: 0};

    while (matchesByPool.values.any((list) => list.isNotEmpty)) {
      for (var pool in matchesByPool.keys) {
        if (matchesByPool[pool]!.isEmpty) continue;

        bool matchAdded = false;

        for (int i = 0; i < matchesByPool[pool]!.length; i++) {
          var candidate = matchesByPool[pool]![i];

          if (smartSchedule.isEmpty ||
              (smartSchedule.last['team1'] != candidate['team1'] &&
                  smartSchedule.last['team2'] != candidate['team1'] &&
                  smartSchedule.last['team1'] != candidate['team2'] &&
                  smartSchedule.last['team2'] != candidate['team2'])) {

            smartSchedule.add(candidate);
            matchesByPool[pool]!.removeAt(i);
            matchAdded = true;
            break;
          }
        }

        if (!matchAdded && matchesByPool[pool]!.isNotEmpty) {
          // No conflict-free match — pick first available
          smartSchedule.add(matchesByPool[pool]!.removeAt(0));
        }
      }
    }

    setState(() {
      combinedFixtures = smartSchedule;
      fixturesGenerated = true;
    });
  }

  @override
  void dispose() {
    _poolCountController.dispose();
    for (var pool in teamControllers) {
      for (var c in pool) {
        c.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixtures 📝'),
      ),
      body: fixturesGenerated
          ? ListView.builder(
        itemCount: combinedFixtures.length,
        itemBuilder: (context, index) {
          var fixture = combinedFixtures[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: fixture['done'] ? Colors.grey[300] : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                        "${index + 1}. ${fixture['team1']} vs ${fixture['team2']}"),
                    subtitle: Text(fixture['pool']),
                    trailing: Checkbox(
                      value: fixture['done'],
                      onChanged: (value) {
                        setState(() {
                          fixture['done'] = value!;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Winner: '),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: fixture['team1'],
                            groupValue: fixture['winner'],
                            onChanged: (value) {
                              setState(() {
                                fixture['winner'] = value;
                              });
                            },
                          ),
                          Text(fixture['team1']),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: fixture['team2'],
                            groupValue: fixture['winner'],
                            onChanged: (value) {
                              setState(() {
                                fixture['winner'] = value;
                              });
                            },
                          ),
                          Text(fixture['team2']),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _poolCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'How many Pools?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_poolCountController.text.isNotEmpty) {
                  setState(() {
                    poolCount = int.parse(_poolCountController.text);
                    createTeamInputs();
                  });
                }
              },
              child: const Text('Create Pools'),
            ),
            const SizedBox(height: 20),
            ...List.generate(poolCount, (poolIndex) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pool ${poolIndex + 1}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...List.generate(teamControllers[poolIndex].length, (teamIndex) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: TextField(
                        controller: teamControllers[poolIndex][teamIndex],
                        decoration: InputDecoration(
                          labelText: 'Team ${teamIndex + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        teamControllers[poolIndex].add(TextEditingController());
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Team'),
                  ),
                  const Divider(height: 30),
                ],
              );
            }),
            if (poolCount > 0)
              ElevatedButton.icon(
                onPressed: () {
                  bool allEntered = true;
                  for (var pool in teamControllers) {
                    if (pool.isEmpty || pool.any((c) => c.text.isEmpty)) {
                      allEntered = false;
                      break;
                    }
                  }

                  if (allEntered) {
                    generateFixtures();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter all team names')),
                    );
                  }
                },
                icon: const Icon(Icons.sports_cricket),
                label: const Text('Generate Fixtures'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
          ],
        ),
      ),
    );
  }
}