class Monster {
  Monster({
    required this.creature,
    required this.information,
  });
  late final Creature creature;
  late final Information information;

  Monster.fromJson(Map<String, dynamic> json) {
    creature = Creature.fromJson(json['creature']);
    information = Information.fromJson(json['information']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['creature'] = creature.toJson();
    _data['information'] = information.toJson();
    return _data;
  }
}

class Creature {
  Creature({
    this.beConvinced,
    this.beParalysed,
    this.beSummoned,
    this.behaviour,
    this.convincedMana,
    this.description,
    this.experiencePoints,
    this.featured,
    this.hitpoints,
    this.imageUrl,
    this.isLootable,
    this.name,
    this.race,
    this.seeInvisible,
    this.summonedMana,
  });
  late final bool? beConvinced;
  late final bool? beParalysed;
  late final bool? beSummoned;
  late final String? behaviour;
  late final int? convincedMana;
  late final String? description;
  late final int? experiencePoints;
  late final bool? featured;
  late final int? hitpoints;
  late final String? imageUrl;
  late final bool? isLootable;
  late final String? name;
  late final String? race;
  late final bool? seeInvisible;
  late final int? summonedMana;

  Creature.fromJson(Map<String, dynamic> json) {
    beConvinced = json['be_convinced'];
    beParalysed = json['be_paralysed'];
    beSummoned = json['be_summoned'];
    behaviour = json['behaviour'];
    convincedMana = json['convinced_mana'];
    description = json['description'];
    experiencePoints = json['experience_points'];
    featured = json['featured'];
    hitpoints = json['hitpoints'];
    imageUrl = json['image_url'];
    isLootable = json['is_lootable'];
    name = json['name'];
    race = json['race'];
    seeInvisible = json['see_invisible'];
    summonedMana = json['summoned_mana'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['be_convinced'] = beConvinced;
    _data['be_paralysed'] = beParalysed;
    _data['be_summoned'] = beSummoned;
    _data['behaviour'] = behaviour;
    _data['convinced_mana'] = convincedMana;
    _data['description'] = description;
    _data['experience_points'] = experiencePoints;
    _data['featured'] = featured;
    _data['hitpoints'] = hitpoints;
    _data['image_url'] = imageUrl;
    _data['is_lootable'] = isLootable;
    _data['name'] = name;
    _data['race'] = race;
    _data['see_invisible'] = seeInvisible;
    _data['summoned_mana'] = summonedMana;
    return _data;
  }
}

class Information {
  Information({
    required this.apiVersion,
    required this.timestamp,
  });
  late final int apiVersion;
  late final String timestamp;

  Information.fromJson(Map<String, dynamic> json) {
    apiVersion = json['api_version'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['api_version'] = apiVersion;
    _data['timestamp'] = timestamp;
    return _data;
  }
}
