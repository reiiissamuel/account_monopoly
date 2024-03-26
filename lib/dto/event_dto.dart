import 'package:account_monopoly/dto/player.dart';
import 'package:account_monopoly/enums/enums.dart';
import 'package:account_monopoly/model/game_model.dart';

import '../utils/string_utils.dart';
import 'auction.dart';

class EventDTO{

  late final String eventId;
  final LogMsgType type;
  final Player? destinationPlayer;
  final Player sourcePlayer;
  late final GameModelDTO? gameData; ///somente enviado nos eventos do tipo HANDSHAKE para passar as confi do jogo para um novo player
  final int? value;

  final Auction? auction;

  EventDTO({String ?eventId, this.gameData, required this.type, this.destinationPlayer, required this.sourcePlayer,
    this.value, this.auction}){
    this.eventId = eventId ?? "${StringUtils.generateUUID(size: 8)}-${sourcePlayer.username}";
  }

  toMap() {
    return {
      "eventId": eventId,
      "LogMsgType": type,
      "destinationPlayer": destinationPlayer?.toMap(),
      "sourcePlayer": sourcePlayer.toMap(),
      "value": value,
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
        auction: map['auction'] != null ? Auction.fromMap(map['auction']) : null,
        gameData: GameModelDTO.fromMap( map['gameData'])
    );}
}