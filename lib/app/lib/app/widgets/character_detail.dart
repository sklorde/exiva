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
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Image.asset(
                          vocationImages[
                              player.characters?.character!.vocation]!,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(player.characters?.character!.vocation)}',
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
                          if (player.characters?.character!.comment != null)
                            Text(
                              '"${player.characters?.character!.comment}"',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 4,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.7,
                              children: [
                                _buildInfo(
                                    'LEVEL',
                                    player.characters?.character?.level
                                        ?.toString()),
                                _buildInfo(
                                    'SEX', player.characters?.character?.sex),
                                _buildInfo('WORLD',
                                    player.characters?.character?.world),
                                _buildInfo('RESIDENCE',
                                    player.characters?.character?.residence),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfo(String title, String? value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
          value?.toUpperCase() ?? '',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
