class Match {
  final String teamA;
  final String teamB;
  final String poolName;
  bool isCompleted;
  bool? winnerIsTeamA;

  Match({
    required this.teamA,
    required this.teamB,
    required this.poolName,
    this.isCompleted = false,
    this.winnerIsTeamA,
  });
}