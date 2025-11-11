import 'package:account_monopoly/domain/model/chance.dart';
import 'package:account_monopoly/domain/model/ledger.dart';
import 'package:account_monopoly/domain/model/player.dart';

class GameModelDTO{
  String id = "";
  double initalGameCredit = 0;
  int limitPlayer = 0;
  int currentRound = 0;
  Ledger ledger = Ledger.empty();
  Player player = Player.empty();
  Map<String, Player> othersPlayers;
  List<String> logs = [];
  List<Chance> chances = [];


  bool loanEnabled = false;
  bool chancesEnabled = false;
  Player? winner;

  GameModelDTO.empty() : this.othersPlayers = {} ;
  GameModelDTO({Player ?player, required this.ledger, required this.id, required this.initalGameCredit,
    required this.limitPlayer, required this.loanEnabled, required this.chancesEnabled, this.othersPlayers = const{}});
  GameModelDTO.initAllFields({required this.player, required this.ledger, required this.id, required this.initalGameCredit, required this.limitPlayer,
    required this.othersPlayers, required this.logs, required this.chances,
     required this.loanEnabled, required this.chancesEnabled, this.winner});
 
  GameModelDTO toInitialTemplate(){
    return GameModelDTO(
      id: id,
      initalGameCredit: initalGameCredit,
      ledger: ledger,
      player: player,
      limitPlayer: limitPlayer,
      othersPlayers: othersPlayers,
      loanEnabled: loanEnabled,
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
      'ledger': ledger.toMap(),
      'othersPlayers': othersPlayers.map((key, value) => MapEntry(key, value.toMap())),
      'logs': logs,
      'chances': chances.map((chance) => chance.toMap()).toList(),
      'initalGameCredit': initalGameCredit,
      'loanEnabled': loanEnabled,
      'chancesEnabled': chancesEnabled,
      'limitPlayer': limitPlayer,
      'winner': winner
    };
  }

  factory GameModelDTO.fromMap(Map<String, dynamic> map) {
    try {
      return GameModelDTO.initAllFields(
        id: map['id'] as String,
        othersPlayers: (map['othersPlayers'] as Map<String, dynamic>? ?? {}).map(
          (key, p) => MapEntry(key, Player.fromMap(p as Map<String, dynamic>)),
        ),
        logs: (map['logs'] as List<dynamic>).cast<String>(),
        chances: (map['chances'] as List<dynamic>).map((b) => Chance.fromMap(b as Map<String, dynamic>)).toList(),
        initalGameCredit: map['initalGameCredit'] as double,
        loanEnabled: map['loanEnabled'] as bool,
        chancesEnabled: map['chancesEnabled'] as bool,
        player: Player.fromMap(map['player'] as Map<String, dynamic>),
        ledger: Ledger.fromMap(map['ledger'] as Map<String, dynamic>),
        limitPlayer: map['limitPlayer'] as int,
        winner: Player.fromMap(map['winner'] as Map<String, dynamic>? ?? {})
    );
    } catch (e) {
      print(e);
      return GameModelDTO.empty();
    }
  }
}