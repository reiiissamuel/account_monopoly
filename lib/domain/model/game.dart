import 'dart:developer';

import 'package:account_monopoly/domain/model/chance.dart';
import 'package:account_monopoly/domain/model/ledger.dart';
import 'package:account_monopoly/domain/model/player.dart';

class GameModelDTO{
 String id = "";
 double initalGameCredit = 0;
 int limitPlayer = 0;
 int? roundsLimit;
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
  required this.limitPlayer, this.roundsLimit, required this.loanEnabled, required this.chancesEnabled}) : othersPlayers = {};
 GameModelDTO.initAllFields({required this.player, required this.ledger, required this.id, required this.initalGameCredit, required this.limitPlayer,
  required this.roundsLimit,
  required this.othersPlayers, /*required this.logs, this.chances,*/
  required this.loanEnabled, required this.chancesEnabled, this.winner});

 GameModelDTO toInitialTemplate(){
  return GameModelDTO(
   id: id,
   initalGameCredit: initalGameCredit,
   ledger: ledger,
   player: player,
   limitPlayer: limitPlayer,
   roundsLimit: roundsLimit,
   loanEnabled: loanEnabled,
   chancesEnabled: chancesEnabled
  );
 }

 bool get isEmpty => id.isEmpty;
 int get currentPlayerRound => player.financialReport.historicalBalances.length + 1;

 void updateOtherPlayers(Player? player){
  if(player == null) return;
  final p = othersPlayers.values.firstWhere((p) => p.username == player.username, orElse: () => player);
  othersPlayers[p.id] = player;
 }

 void _generatePlayersRaking(){
    othersPlayers.values.toList().sort((a, b) {
        double netWorthA = a.netWorth(
          ledger.getSharesHolderSummary(a.portfolio).totalPortfolioValue,
        );
        double netWorthB = b.netWorth(
          ledger.getSharesHolderSummary(b.portfolio).totalPortfolioValue,
        );
        return netWorthB.compareTo(netWorthA);
      });
  }

  int _countActivePlayers() {
    return othersPlayers.values.where((p) => !p.youBankrupt).length;
  }

  bool checkForAWinner() {
    updateOtherPlayers(player); 
    if((roundsLimit != null && currentPlayerRound >= roundsLimit!) || _countActivePlayers() <= 1){
      _generatePlayersRaking();
      winner = othersPlayers.values.first;
      return true;
    }
    return false;
  }

  void addGameEventsLog(String log){
    if(log.trim().isNotEmpty) {
      logs.add(log);
    }
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
   'roundsLimit': roundsLimit,
   'winner': winner?.toMap(),
   //'chances': chances.map((chance) => chance.toMap()).toList(),
  };
 }

 factory GameModelDTO.fromMap(Map<String, dynamic> map) {
  try {
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
    limitPlayer: (map['limitPlayer'] as num?)?.toInt() ?? 4,
    roundsLimit: (map['roundsLimit'] as num?)?.toInt() ?? null,
    winner: restoredWinner,
    //chances: (map['chances'] as List<dynamic>).map((b) => Chance.fromMap(b as Map<String, dynamic>)).toList(),
  );
  } catch (e) {
   log('ERRO DE DESSERIALIZAÇÃO DE GameModelDTO: $e');
   return GameModelDTO.empty();
  }
 }
}