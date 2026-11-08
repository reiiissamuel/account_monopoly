import 'package:account_monopoly/domain/model/player.dart';
import 'package:account_monopoly/domain/model/loan.dart';

class BlacklistedPlayerDto {
  final Player player;
  final Loan openLoan;
  int _roundsInBlacklist = 0;

  BlacklistedPlayerDto({
    required this.player,
    required this.openLoan
  });

  void incrementRoundsInBlacklist() {
    _roundsInBlacklist++;
  }

  int get roundsInBlacklist => _roundsInBlacklist;

  factory BlacklistedPlayerDto.fromMap(Map<String, dynamic> map) {
    return BlacklistedPlayerDto(
      player: Player.fromMap(map['player']),
      openLoan: Loan.fromMap(map['openLoan']),
    ).._roundsInBlacklist = map['roundsInBlacklist'] as int? ?? 0;
  }
  
  Map<String, dynamic> toMap() {
    return {
      'player': player.toMap(),
      'openLoan': openLoan.toMap(),
      'roundsInBlacklist': _roundsInBlacklist,
    };
  }
}