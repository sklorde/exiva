import 'package:exiva/app/lib/app/widgets/character_death.dart';
import 'package:exiva/app/lib/app/widgets/character_detail.dart';
import 'package:exiva/app/shared/models/player.dart';
import 'package:flutter/material.dart';

class CharacterCard extends StatelessWidget {
  final Player player;
  const CharacterCard({Key? key, required this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              indicatorColor: Color.fromRGBO(187, 148, 94, 1),
              tabs: [
                Tab(icon: Text('Details')),
                Tab(icon: Text('Deaths')),
              ],
            ),
            title: const Text('Player'),
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(187, 148, 94, 1),
          ),
          body: TabBarView(
            children: [
              CharacterDetail(player: player),
              CharacterDeath(player: player),
            ],
          ),
        ),
      ),
    );
  }
}
