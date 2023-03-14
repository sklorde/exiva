class Player {
  final Characters? characters;
  final Information? information;

  Player({
    this.characters,
    this.information,
  });

  Player.fromJson(Map<String, dynamic> json)
      : characters = (json['characters'] as Map<String, dynamic>?) != null
            ? Characters.fromJson(json['characters'] as Map<String, dynamic>)
            : null,
        information = (json['information'] as Map<String, dynamic>?) != null
            ? Information.fromJson(json['information'] as Map<String, dynamic>)
            : null;

  Map<String, dynamic> toJson() => {
        'characters': characters?.toJson(),
        'information': information?.toJson()
      };
}

class Characters {
  final List<AccountBadges>? accountBadges;
  final AccountInformation? accountInformation;
  final List<Achievements>? achievements;
  final Character? character;
  final List<Deaths>? deaths;
  final List<OtherCharacters>? otherCharacters;

  Characters({
    this.accountBadges,
    this.accountInformation,
    this.achievements,
    this.character,
    this.deaths,
    this.otherCharacters,
  });

  Characters.fromJson(Map<String, dynamic> json)
      : accountBadges = (json['account_badges'] as List?)
            ?.map((dynamic e) =>
                AccountBadges.fromJson(e as Map<String, dynamic>))
            .toList(),
        accountInformation =
            (json['account_information'] as Map<String, dynamic>?) != null
                ? AccountInformation.fromJson(
                    json['account_information'] as Map<String, dynamic>)
                : null,
        achievements = (json['achievements'] as List?)
            ?.map(
                (dynamic e) => Achievements.fromJson(e as Map<String, dynamic>))
            .toList(),
        character = (json['character'] as Map<String, dynamic>?) != null
            ? Character.fromJson(json['character'] as Map<String, dynamic>)
            : null,
        deaths = (json['deaths'] as List?)
            ?.map((dynamic e) => Deaths.fromJson(e as Map<String, dynamic>))
            .toList(),
        otherCharacters = (json['other_characters'] as List?)
            ?.map((dynamic e) =>
                OtherCharacters.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'account_badges': accountBadges?.map((e) => e.toJson()).toList(),
        'account_information': accountInformation?.toJson(),
        'achievements': achievements?.map((e) => e.toJson()).toList(),
        'character': character?.toJson(),
        'deaths': deaths?.map((e) => e.toJson()).toList(),
        'other_characters': otherCharacters?.map((e) => e.toJson()).toList()
      };
}

class AccountBadges {
  final String? description;
  final String? iconUrl;
  final String? name;

  AccountBadges({
    this.description,
    this.iconUrl,
    this.name,
  });

  AccountBadges.fromJson(Map<String, dynamic> json)
      : description = json['description'] as String?,
        iconUrl = json['icon_url'] as String?,
        name = json['name'] as String?;

  Map<String, dynamic> toJson() =>
      {'description': description, 'icon_url': iconUrl, 'name': name};
}

class AccountInformation {
  final String? created;
  final String? loyaltyTitle;
  final String? position;

  AccountInformation({
    this.created,
    this.loyaltyTitle,
    this.position,
  });

  AccountInformation.fromJson(Map<String, dynamic> json)
      : created = json['created'] as String?,
        loyaltyTitle = json['loyalty_title'] as String?,
        position = json['position'] as String?;

  Map<String, dynamic> toJson() =>
      {'created': created, 'loyalty_title': loyaltyTitle, 'position': position};
}

class Achievements {
  final int? grade;
  final String? name;
  final bool? secret;

  Achievements({
    this.grade,
    this.name,
    this.secret,
  });

  Achievements.fromJson(Map<String, dynamic> json)
      : grade = json['grade'] as int?,
        name = json['name'] as String?,
        secret = json['secret'] as bool?;

  Map<String, dynamic> toJson() =>
      {'grade': grade, 'name': name, 'secret': secret};
}

class Character {
  final String? accountStatus;
  final int? achievementPoints;
  final String? comment;
  final String? deletionDate;
  final List<String>? formerNames;
  final List<String>? formerWorlds;
  final Guild? guild;
  final List<Houses>? houses;
  final String? lastLogin;
  final int? level;
  final String? marriedTo;
  final String? name;
  final String? residence;
  final String? sex;
  final String? title;
  final bool? traded;
  final int? unlockedTitles;
  final String? vocation;
  final String? world;

  Character({
    this.accountStatus,
    this.achievementPoints,
    this.comment,
    this.deletionDate,
    this.formerNames,
    this.formerWorlds,
    this.guild,
    this.houses,
    this.lastLogin,
    this.level,
    this.marriedTo,
    this.name,
    this.residence,
    this.sex,
    this.title,
    this.traded,
    this.unlockedTitles,
    this.vocation,
    this.world,
  });

  Character.fromJson(Map<String, dynamic> json)
      : accountStatus = json['account_status'] as String?,
        achievementPoints = json['achievement_points'] as int?,
        comment = json['comment'] as String?,
        deletionDate = json['deletion_date'] as String?,
        formerNames = (json['former_names'] as List?)
            ?.map((dynamic e) => e as String)
            .toList(),
        formerWorlds = (json['former_worlds'] as List?)
            ?.map((dynamic e) => e as String)
            .toList(),
        guild = (json['guild'] as Map<String, dynamic>?) != null
            ? Guild.fromJson(json['guild'] as Map<String, dynamic>)
            : null,
        houses = (json['houses'] as List?)
            ?.map((dynamic e) => Houses.fromJson(e as Map<String, dynamic>))
            .toList(),
        lastLogin = json['last_login'] as String?,
        level = json['level'] as int?,
        marriedTo = json['married_to'] as String?,
        name = json['name'] as String?,
        residence = json['residence'] as String?,
        sex = json['sex'] as String?,
        title = json['title'] as String?,
        traded = json['traded'] as bool?,
        unlockedTitles = json['unlocked_titles'] as int?,
        vocation = json['vocation'] as String?,
        world = json['world'] as String?;

  Map<String, dynamic> toJson() => {
        'account_status': accountStatus,
        'achievement_points': achievementPoints,
        'comment': comment,
        'deletion_date': deletionDate,
        'former_names': formerNames,
        'former_worlds': formerWorlds,
        'guild': guild?.toJson(),
        'houses': houses?.map((e) => e.toJson()).toList(),
        'last_login': lastLogin,
        'level': level,
        'married_to': marriedTo,
        'name': name,
        'residence': residence,
        'sex': sex,
        'title': title,
        'traded': traded,
        'unlocked_titles': unlockedTitles,
        'vocation': vocation,
        'world': world
      };
}

class Guild {
  final String? name;
  final String? rank;

  Guild({
    this.name,
    this.rank,
  });

  Guild.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String?,
        rank = json['rank'] as String?;

  Map<String, dynamic> toJson() => {'name': name, 'rank': rank};
}

class Houses {
  final int? houseid;
  final String? name;
  final String? paid;
  final String? town;

  Houses({
    this.houseid,
    this.name,
    this.paid,
    this.town,
  });

  Houses.fromJson(Map<String, dynamic> json)
      : houseid = json['houseid'] as int?,
        name = json['name'] as String?,
        paid = json['paid'] as String?,
        town = json['town'] as String?;

  Map<String, dynamic> toJson() =>
      {'houseid': houseid, 'name': name, 'paid': paid, 'town': town};
}

class Deaths {
  final List<Assists>? assists;
  final List<Killers>? killers;
  final int? level;
  final String? reason;
  final String? time;

  Deaths({
    this.assists,
    this.killers,
    this.level,
    this.reason,
    this.time,
  });

  Deaths.fromJson(Map<String, dynamic> json)
      : assists = (json['assists'] as List?)
            ?.map((dynamic e) => Assists.fromJson(e as Map<String, dynamic>))
            .toList(),
        killers = (json['killers'] as List?)
            ?.map((dynamic e) => Killers.fromJson(e as Map<String, dynamic>))
            .toList(),
        level = json['level'] as int?,
        reason = json['reason'] as String?,
        time = json['time'] as String?;

  Map<String, dynamic> toJson() => {
        'assists': assists?.map((e) => e.toJson()).toList(),
        'killers': killers?.map((e) => e.toJson()).toList(),
        'level': level,
        'reason': reason,
        'time': time
      };
}

class Assists {
  final String? name;
  final bool? player;
  final String? summon;
  final bool? traded;

  Assists({
    this.name,
    this.player,
    this.summon,
    this.traded,
  });

  Assists.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String?,
        player = json['player'] as bool?,
        summon = json['summon'] as String?,
        traded = json['traded'] as bool?;

  Map<String, dynamic> toJson() =>
      {'name': name, 'player': player, 'summon': summon, 'traded': traded};
}

class Killers {
  final String? name;
  final bool? player;
  final String? summon;
  final bool? traded;

  Killers({
    this.name,
    this.player,
    this.summon,
    this.traded,
  });

  Killers.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String?,
        player = json['player'] as bool?,
        summon = json['summon'] as String?,
        traded = json['traded'] as bool?;

  Map<String, dynamic> toJson() =>
      {'name': name, 'player': player, 'summon': summon, 'traded': traded};
}

class OtherCharacters {
  final bool? deleted;
  final bool? main;
  final String? name;
  final String? status;
  final bool? traded;
  final String? world;

  OtherCharacters({
    this.deleted,
    this.main,
    this.name,
    this.status,
    this.traded,
    this.world,
  });

  OtherCharacters.fromJson(Map<String, dynamic> json)
      : deleted = json['deleted'] as bool?,
        main = json['main'] as bool?,
        name = json['name'] as String?,
        status = json['status'] as String?,
        traded = json['traded'] as bool?,
        world = json['world'] as String?;

  Map<String, dynamic> toJson() => {
        'deleted': deleted,
        'main': main,
        'name': name,
        'status': status,
        'traded': traded,
        'world': world
      };
}

class Information {
  final int? apiVersion;
  final String? timestamp;

  Information({
    this.apiVersion,
    this.timestamp,
  });

  Information.fromJson(Map<String, dynamic> json)
      : apiVersion = json['api_version'] as int?,
        timestamp = json['timestamp'] as String?;

  Map<String, dynamic> toJson() =>
      {'api_version': apiVersion, 'timestamp': timestamp};
}
