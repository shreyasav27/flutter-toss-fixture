import 'package:flutter/material.dart';
import '../models/match_model.dart';

class MatchCardWidget extends StatelessWidget {
  final Match match;
  final int serialNumber;
  final VoidCallback onToggleWinner;

  const MatchCardWidget({
    required this.match,
    required this.serialNumber,
    required this.onToggleWinner,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: match.isCompleted ? Colors.green.shade100 : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Text(
          '$serialNumber.',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        title: Text(
          '${match.teamA} vs ${match.teamB} (${match.poolName})',
          style: const TextStyle(fontSize: 15),
        ),
        trailing: Checkbox(
          value: match.isCompleted,
          onChanged: (value) => onToggleWinner(),
        ),
      ),
    );
  }
}