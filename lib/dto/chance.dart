import 'dart:convert';

import 'package:flutter/services.dart';

class EventController {
  List<Event> events = List.empty();

  Future<String> _loadEventFromJson() async {
    return await rootBundle.loadString('jsondata/chances.json');
  }

  Future<List> getAllEvents() async {
    String jsonString = await _loadEventFromJson();
    var eventsObjJson = jsonDecode(jsonString)["events"] as List;
    events = eventsObjJson
        .map((eventsJson) => Event.fromJson(eventsJson))
        .toList();

    return events;
  }
}

class Event {
  int? id;
  String? name;
  String? description;
  int? effect;
  String? incoming;
  bool? isbenefit;

  Event({required int id, required String name, required String description, required int effect, required String incoming, required bool isbenefit});

  factory Event.fromJson(dynamic json) {
    return Event(
        name: json['name'] as String,
        id: json['id'] as int,
        description: json['description'] as String,
        effect: json['effect'] as int,
        incoming: json['incoming'] as String,
        isbenefit: json['isbenefit'] as bool);
  }

  Map<String, dynamic> toMap() {
    return {
      'id':  id,
      'name': name,
      'description': description,
      'effect': effect,
      'incoming':  incoming,
      'isbenefit': isbenefit
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
        id: map['id'] as int,
        name: map['name'] as String,
        description: map['description'] as String,
        effect: map['effect'] as int,
        incoming: map['incoming'] as String,
        isbenefit: map['isbenefit'] as bool
    );}
}