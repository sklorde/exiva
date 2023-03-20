import 'package:dio/dio.dart';
import 'package:exiva/app/shared/models/player.dart';

class TibiaDataSource {
  final Dio dio = Dio();

  TibiaDataSource() {
    dio.options.baseUrl = 'https://api.tibiadata.com/v3';
  }

  Future<Player> getPlayer(String? name) async {
    try {
      final result = await dio.get('/character/$name');

      Player player = Player.fromJson(result.data);

      print(player.characters?.character!.vocation);

      return Player.fromJson(result.data);
    } catch (error) {
      throw Exception();
    }
  }
}
