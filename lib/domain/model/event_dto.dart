import 'package:account_monopoly/domain/model/game_model_dto.dart';
import 'package:account_monopoly/domain/model/player.dart';
import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/domain/model/trade_offer.dart';

import 'package:account_monopoly/utils/string_utils.dart';

class EventDTO{

  late final String eventId;
  final EventType type;
  final Player? destinationPlayer;
  final Player sourcePlayer;
  late final GameModelDTO? gameData; ///somente enviado nos eventos do tipo HANDSHAKE para passar as confi do jogo para um novo player
  num? value;
  Property? property;
  TradeOffer? tradeOffer;


  EventDTO({String ?eventId, this.gameData, required this.type, this.destinationPlayer, required this.sourcePlayer,
    this.value, this.property, this.tradeOffer}){
    this.eventId = eventId ?? "${StringUtils.generateUUID(size: 8)}-${sourcePlayer.username}";
  }

  String getEventLog(Player currentPlayer){
    return type.messageScope
          !.replaceAll('{SOURCE}', sourcePlayer.username == currentPlayer.username ? 'Sua empresa' : currentPlayer.username)
            .replaceAll('{VALUE}', (value is double) ? StringUtils.currencyFormat(value!.toDouble()) : value.toString())
              .replaceAll('{DEST}', (destinationPlayer != null && destinationPlayer?.username == currentPlayer.username) ? 'Sua empresa' : sourcePlayer.username)
              .replaceAll('{PROPERTY}', property!.name)
              .replaceAll('{TRADEOFFER}', "\n\t${tradeOffer?.sharesAmount} ações de ${tradeOffer?.offerId} no valor total de ${tradeOffer?.totalAskingPrice}");
     
  }

  Map<String, dynamic> toMap() {
    return {
      "eventId": eventId,
      "EventType": type,
      "destinationPlayer": destinationPlayer?.toMap(),
      "sourcePlayer": sourcePlayer.toMap(),
      "value": value,
      "gameData": gameData?.toMap(),
      "property": property?.toMap()
    };
  }

  factory EventDTO.fromMap(Map<String, dynamic> map) {
    return EventDTO(
        eventId: map['eventId'] as String,
        type: map['type'] as EventType,
        destinationPlayer: Player.fromMap(map['destinationPlayer']),
        sourcePlayer: Player.fromMap(map['sourcePlayer']),
        value: map['value'] as num?,
        gameData: GameModelDTO.fromMap( map['gameData']),
        property: map['property'] != null ? Property.fromMap(map['property']) : null
    );}
}