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
      return Player.fromJson(result.data);
    } catch (e) {
      throw Exception();
    }
  }
}
