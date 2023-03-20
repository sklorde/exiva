import 'package:dio/dio.dart';
import 'package:exiva/app/shared/models/player.dart';

import '../models/monster.dart';

class TibiaDataSource {
  final Dio dio = Dio();

  TibiaDataSource() {
    dio.options.baseUrl = 'https://api.tibiadata.com/v3';
  }

  Future<Player> getPlayer(String? name) async {
    try {
      final result = await dio.get('/character/$name');

      Player player = Player.fromJson(result.data);

      if (player.characters?.deaths != null) {
        for (var element in player.characters!.deaths!) {
          for (var killer in element.killers!) {
            killer.monster = await getMonster(killer.name!.replaceAll(' ', ''));
          }
        }
      }

      // player.characters?.deaths[0].killers[0].name

      // player.characters?.deaths[0].killers[0].monster

      return player;
    } catch (error) {
      throw Exception();
    }
  }

  Future<Monster> getMonster(String? creatureName) async {
    try {
      final result = await dio.get('/creature/$creatureName');

      return Monster.fromJson(result.data);
    } catch (error) {
      throw Exception();
    }
  }
}
