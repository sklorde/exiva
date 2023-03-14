import 'package:exiva/app/shared/models/player.dart';
import 'package:exiva/app/shared/repositories/tibia_datasource.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_triple/flutter_triple.dart';

class HomeStore extends NotifierStore<Exception, Player> {
  HomeStore() : super(Player());
  final datasource = TibiaDataSource();
  final TextEditingController textController = TextEditingController();

  Future<void> getPlayer(String? name) async {
    setLoading(true);
    update(await datasource.getPlayer(name));
    setLoading(false);
  }
}
