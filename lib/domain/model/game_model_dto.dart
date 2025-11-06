import 'dart:collection';

import 'package:account_monopoly/domain/model/chance.dart';
import 'package:account_monopoly/domain/model/ledger.dart';
import 'package:account_monopoly/domain/model/player.dart';

class GameModelDTO{
  String id = "";
  double initalGameCredit = 0;
  int limitPlayer = 0;
  double roundBonus = 0;
  int currentRound = 0;
  Ledger ledger = Ledger.empty();
  Player player = Player.empty();
  Map<String, Player> othersPlayers = {};
  List<String> logs = [];
  List<Chance> chances = [];

  bool auctionEnabled = false;
  bool mortgageEnabled = false;
  bool chancesEnabled = false;
  Player winner = Player.empty();

  GameModelDTO.empty();
  GameModelDTO({Player ?player, required ledger, required this.id, required this.initalGameCredit, required this.roundBonus,
    required this.limitPlayer, required this.othersPlayers, required this.mortgageEnabled, required this.chancesEnabled});
  GameModelDTO.initAllFields({required this.player, required ledeger, required this.id, required this.initalGameCredit, required this.limitPlayer,
    required this.othersPlayers, required this.logs, required this.chances, required this.roundBonus, required this.auctionEnabled, required this.mortgageEnabled, required this.chancesEnabled});
 
  GameModelDTO toInitialTemplate(){
    return GameModelDTO(
      id: id,
      initalGameCredit: initalGameCredit,
      roundBonus: roundBonus,
      ledger: ledger,
      player: player,
      limitPlayer: limitPlayer,
      othersPlayers: othersPlayers,
      mortgageEnabled: mortgageEnabled,
      chancesEnabled: chancesEnabled
    );
  }

  void updateOtherPlayers(Player player){
    othersPlayers[player.id] == player;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'player' : player.toMap(),
      'ledger': ledger,
      'othersPlayers': othersPlayers.map((key, value) => MapEntry(key, value.toMap())),
      'logs': logs,
      'chances': chances.map((chance) => chance.toMap()).toList(),
      'initalGameCredit': initalGameCredit,
      'auctionEnabled': auctionEnabled,
      'mortgageEnabled': mortgageEnabled,
      'chancesEnabled': chancesEnabled,
      'roundBonus': roundBonus,
      'limitPlayer': limitPlayer
    };
  }

  factory GameModelDTO.fromMap(Map<String, dynamic> map) {
    return GameModelDTO.initAllFields(
        id: map['id'] as String,
        othersPlayers: (map['othersPlayers'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(key, Player.fromMap(value as Map<String, dynamic>)),
        ),
        logs: (map['logs'] as List<dynamic>).cast<String>(),
        chances: (map['chances'] as List<dynamic>).map((b) => Chance.fromMap(b as Map<String, dynamic>)).toList(),
        roundBonus:  map['roundBonus'] as double,
        initalGameCredit: map['initalGameCredit'] as double,
        auctionEnabled: map['auctionEnabled'] as bool,
        mortgageEnabled: map['mortgageEnabled'] as bool,
        chancesEnabled: map['chancesEnabled'] as bool,
        player: Player.fromMap(map['player'] as Map<String, dynamic>),
        ledeger: Ledger.empty(),
        limitPlayer: map['limitPlayer'] as int
    );
  }
}