import 'dart:developer';

import 'package:account_monopoly/domain/model/chance.dart';
import 'package:account_monopoly/domain/model/ledger.dart';
import 'package:account_monopoly/domain/model/player.dart';

class GameModelDTO{
 String id = "";
 double initalGameCredit = 0;
 int limitPlayer = 0;
 int currentRound = 1;
 Ledger ledger = Ledger.empty();
 Player player = Player.empty();
 Map<String, Player> othersPlayers;
 List<String> logs = [];
 List<Chance> chances = [];


 bool loanEnabled = false;
 bool chancesEnabled = false;
 Player? winner;

 GameModelDTO.empty() : othersPlayers = {} ;
 GameModelDTO({Player ?player, required this.ledger, required this.id, required this.initalGameCredit,
  required this.limitPlayer, required this.loanEnabled, required this.chancesEnabled}) : othersPlayers = {};
 GameModelDTO.initAllFields({required this.player, required this.ledger, required this.id, required this.initalGameCredit, required this.limitPlayer,
  required this.othersPlayers, /*required this.logs, this.chances,*/
  required this.loanEnabled, required this.chancesEnabled, this.winner});

 GameModelDTO toInitialTemplate(){
  return GameModelDTO(
   id: id,
   initalGameCredit: initalGameCredit,
   ledger: ledger,
   player: player,
   limitPlayer: limitPlayer,
   loanEnabled: loanEnabled,
   chancesEnabled: chancesEnabled
  );
 }

 void updateOtherPlayers(Player player){
  othersPlayers[player.id] = player;
 }

 Map<String, dynamic> toMap() {
  return {
   'id': id,
   'player' : player.toMap(),
   'ledger': ledger.toMap(),
   'othersPlayers': othersPlayers.map((key, value) => MapEntry(key, value.toMap())),
   //'logs': logs,
   'initalGameCredit': initalGameCredit,
   'loanEnabled': loanEnabled,
   'chancesEnabled': chancesEnabled,
   'limitPlayer': limitPlayer,
   'winner': winner?.toMap(),
   //'chances': chances.map((chance) => chance.toMap()).toList(),
  };
 }

 factory GameModelDTO.fromMap(Map<String, dynamic> map) {
  try {
   /* final List<String> safeLogs = (map['logs'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? []; */
      
    final Player? restoredWinner = map['winner'] != null 
        ? Player.fromMap(map['winner'] as Map<String, dynamic>) 
        : null;
   return GameModelDTO.initAllFields(
    id: map['id'] as String,
    othersPlayers: (map['othersPlayers'] as Map<String, dynamic>? ?? {}).map(
     (key, p) => MapEntry(key, Player.fromMap(p as Map<String, dynamic>)),
    ),
    //logs: safeLogs,
    initalGameCredit: map['initalGameCredit'] is int ? (map['initalGameCredit'] as int).toDouble() : map['initalGameCredit'] as double,
    loanEnabled: map['loanEnabled'] as bool,
    chancesEnabled: map['chancesEnabled'] as bool,
    player: Player.fromMap(map['player'] as Map<String, dynamic>),
    ledger: Ledger.fromMap(map['ledger'] as Map<String, dynamic>),
    limitPlayer: map['limitPlayer'] as int,
    winner: restoredWinner,
    //chances: (map['chances'] as List<dynamic>).map((b) => Chance.fromMap(b as Map<String, dynamic>)).toList(),
  );
  } catch (e) {
   log('ERRO DE DESSERIALIZAÇÃO DE GameModelDTO: $e');
   return GameModelDTO.empty();
  }
 }
}