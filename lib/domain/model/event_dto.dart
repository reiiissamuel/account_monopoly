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
  GameModelDTO? gameData; ///somente enviado nos eventos do tipo HANDSHAKE para passar as confi do jogo para um novo player
  int referenceRound;
  num? value;
  Property? property;
  TradeOffer? tradeOffer;


  EventDTO({String ?eventId, this.gameData, required this.type, this.destinationPlayer, required this.sourcePlayer, this.referenceRound = 0,
    this.value, this.property, this.tradeOffer}){
    this.eventId = eventId ?? "${StringUtils.generateUUID(size: 8)}-${sourcePlayer.username}";
  }

  String getEventLog(Player currentPlayer){
    String message = type.messageScope
          !.replaceAll('{SOURCE}', sourcePlayer.username == currentPlayer.username ? 'Sua empresa' : sourcePlayer.username)
            .replaceAll('{VALUE}', (value is double) ? StringUtils.currencyFormat(value!.toDouble()) : value.toString())
              .replaceAll('{DEST}', (destinationPlayer != null && destinationPlayer?.username == currentPlayer.username) ? 'Sua empresa' : sourcePlayer.username)
              .replaceAll('{PROPERTY}', (property != null ? property!.name : ""))
              .replaceAll('{TRADEOFFER}', tradeOffer != null ? "\n\t${tradeOffer?.sharesAmount} ações de ${tradeOffer!.propertyId} no valor total de ${StringUtils.currencyFormat(tradeOffer!.totalAskingPrice)}" : "")
              .replaceAll('{ROUND}', referenceRound.toString());
    return message;
  }

  Map<String, dynamic> toMap() {
    return {
      "eventId": eventId,
      "EventType": type.name,
      "destinationPlayer": destinationPlayer?.toMap(),
      "sourcePlayer": sourcePlayer.toMap(),
      "value": value,
      "gameData": gameData?.toMap(),
      "property": property?.toMap(),
      'referenceRound': referenceRound
    };
  }

  factory EventDTO.fromMap(Map<String, dynamic> map) {
    EventType parsedType = EventType.values.firstWhere((e) => e.name == map['EventType']);
    return EventDTO(
        eventId: map['eventId'] as String,
        type: parsedType,
        destinationPlayer: map['destinationPlayer'] != null ? Player.fromMap(map['destinationPlayer']) : null,
        sourcePlayer: Player.fromMap(map['sourcePlayer']),
        value: map['value'] as num?,
        gameData: map['gameData'] != null ? GameModelDTO.fromMap( map['gameData']) : null,
        property: map['property'] != null ? Property.fromMap(map['property']) : null,
        referenceRound: map['referenceRound'] ?? 0
    );}
}