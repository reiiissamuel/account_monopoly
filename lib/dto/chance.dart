
class Chance {
  int? id;
  String? name;
  String? description;
  int? effect;
  String? incoming;
  bool isbenefit;

  Chance({required this.id, required this.name, required this.description, required this.effect, required this.incoming, required this.isbenefit});

  factory Chance.fromJson(dynamic json) {
    return Chance(
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

  factory Chance.fromMap(Map<String, dynamic> map) {
    return Chance(
        id: map['id'] as int,
        name: map['name'] as String,
        description: map['description'] as String,
        effect: map['effect'] as int,
        incoming: map['incoming'] as String,
        isbenefit: map['isbenefit'] as bool
    );}
}