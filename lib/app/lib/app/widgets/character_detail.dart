import 'package:exiva/app/shared/models/player.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CharacterDetail extends StatelessWidget {
  final Player player;
  const CharacterDetail({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Transform.scale(
              scale: 0.8,
              child: FutureBuilder(
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Image.asset(
                      vocationImages[player.characters?.character!.vocation]!,
                    );
                  }
                },
              ),
            ),
            Text(
              '${(player.characters?.character!.vocation)?.toUpperCase()}',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${player.characters?.character!.name}',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            childAspectRatio: 1.0,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              _buildInfo('LEVEL'),
              _buildInfo('SEX'),
              _buildInfo('WORLD'),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildInfo(String title) {
    String? valor;
    switch (title) {
      case 'LEVEL':
        valor = player.characters?.character?.level?.toString();
        break;
      case 'SEX':
        valor = player.characters?.character?.sex;
        break;
      case 'WORLD':
        valor = player.characters?.character?.world;
        break;
      default:
        valor = '';
    }

    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            valor.toString().toUpperCase(),
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

final Map<String, String> vocationImages = {
  'Druid': 'lib/app/shared/utils/images/druid.png',
  'Elder Druid': 'lib/app/shared/utils/images/druid.png',
  'Knight': 'lib/app/shared/utils/images/knight.png',
  'Elite Knight': 'lib/app/shared/utils/images/knight.png',
  'Sorcerer': 'lib/app/shared/utils/images/sorcerer.png',
  'Master Sorcerer': 'lib/app/shared/utils/images/sorcerer.png',
  'Paladin': 'lib/app/shared/utils/images/paladin.png',
  'Royal Paladin': 'lib/app/shared/utils/images/paladin.png',
};
