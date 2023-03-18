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
      child: Column(
        children: [
          Row(
            children: [
              Transform.scale(
                scale: 0.3,
                child: Image.asset('lib/app/shared/utils/gifs/outfit1.gif'),
              ),
              Text(player.characters?.character?.name ?? 'Not found'),
            ],
          ),
        ],
      ),
    );
  }
}
