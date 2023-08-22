import 'package:account_monopoly/dto/player.dart';
import 'package:account_monopoly/enums/enums.dart';
import 'package:account_monopoly/model/game_model.dart';

import 'auction.dart';

class EventDTO{

  final String eventId;
  final LogMsgType type;
  final Player? destinationPlayer;
  final Player sourcePlayer;
  final GameModelDTO? gameData; ///somente enviado nos eventos do tipo HANDSHAKE para passar as confi do jogo para um novo player
  final int? value;

  final bool playerAndHost;

  final Auction? auction;

  EventDTO({this.gameData, required this.eventId, required this.type, this.destinationPlayer, required this.sourcePlayer,
    this.value, required this.playerAndHost, this.auction});

  toMap() {
    return {
      "eventId": eventId,
      "LogMsgType": type,
      "destinationPlayer": destinationPlayer?.toMap(),
      "sourcePlayer": sourcePlayer.toMap(),
      "value": value,
      "playerAndHost": playerAndHost,
      "auction": auction?.toMap(),
      "gameData": gameData?.toMap()
    };
  }

  factory EventDTO.fromMap(Map<String, dynamic> map) {
    return EventDTO(
        eventId: map['eventId'] as String,
        type: map['type'] as LogMsgType,
        destinationPlayer: Player.fromMap(map['destinationPlayer']),
        sourcePlayer: Player.fromMap(map['sourcePlayer']),
        value: map['value'] as int,
        playerAndHost: map['playerAndHost'] as bool,
        auction: map['auction'] != null ? Auction.fromMap(map['auction']) : null,
        gameData: GameModelDTO.fromMap( map['gameData'])
    );}
}