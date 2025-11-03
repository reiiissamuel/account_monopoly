import 'dart:collection';

import 'package:account_monopoly/domain/chance.dart';
import 'package:account_monopoly/domain/model/auction.dart';
import 'package:account_monopoly/domain/model/player.dart';

class GameModelDTO{
  String id = "";
  int initalGameCredit = 0;
  int limitPlayer = 0;
  int levelTax = 0;
  int roundBonus = 0;
  int currentRound = 0;
  Player player = Player.empty();
  Set<Player> othersPlayers = HashSet<Player>();
  List<String> logs = [];
  List<Chance> chances = [];
  List<Auction> auctions = [];

  bool auctionEnabled = false;
  bool mortgageEnabled = false;
  bool chancesEnabled = false;
  bool youWon = false;
  bool youBankrupt = false;

  GameModelDTO.empty();
  GameModelDTO({Player ?player, required this.id, required this.initalGameCredit, required this.roundBonus,
    required this.levelTax, required this.limitPlayer, required this.othersPlayers, required this.mortgageEnabled, required this.chancesEnabled});
  GameModelDTO.initAllFields({required this.id, required this.initalGameCredit,
    required this.othersPlayers, required this.logs, required this.chances, required this.roundBonus,
    required this.youBankrupt, required this.auctions, required this.auctionEnabled, required this.mortgageEnabled, required this.chancesEnabled});
 
  GameModelDTO toInitialTemplate(){
    return GameModelDTO(
      id: id,
      initalGameCredit: initalGameCredit,
      roundBonus: roundBonus,
      player: player,
      levelTax: levelTax,
      limitPlayer: limitPlayer,
      othersPlayers: othersPlayers,
      mortgageEnabled: mortgageEnabled,
      chancesEnabled: chancesEnabled
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'player' : player.toMap(),
      'othersPlayers': othersPlayers.map((player) => player.toMap()).toList(),
      'logs': logs,
      'chances': chances.map((chance) => chance.toMap()).toList(),
      'initalGameCredit': initalGameCredit,
      'youBankrupt': youBankrupt,
      'auctions': auctions,
      'auctionEnabled': auctionEnabled,
      'mortgageEnabled': mortgageEnabled,
      'chancesEnabled': chancesEnabled,
      'roundBonus': roundBonus
    };
  }

  factory GameModelDTO.fromMap(Map<String, dynamic> map) {
    return GameModelDTO.initAllFields(
        id: map['id'] as String,
        othersPlayers: (map['othersPlayers'] as List<dynamic>).map((p) => Player.fromMap(p as Map<String, dynamic>)).toSet(),
        logs: (map['logs'] as List<dynamic>).cast<String>(),
        chances: (map['chances'] as List<dynamic>).map((b) => Chance.fromMap(b as Map<String, dynamic>)).toList(),
        auctions: (map['auctions'] as List<dynamic>).map((b) => Auction.fromMap(b as Map<String, dynamic>)).toList(),
        roundBonus:  map['roundBonus'] as int,
        initalGameCredit: map['initalGameCredit'] as int,
        youBankrupt: map['youBankrupt'] as bool,
        auctionEnabled: map['auctionEnabled'] as bool,
        mortgageEnabled: map['mortgageEnabled'] as bool,
        chancesEnabled: map['chancesEnabled'] as bool
    );
  }
}