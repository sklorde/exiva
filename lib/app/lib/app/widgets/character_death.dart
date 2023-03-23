import 'package:exiva/app/shared/models/player.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

class CharacterDeath extends StatelessWidget {
  final Player player;
  const CharacterDeath({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (player.characters!.deaths == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.scale(
            scale: 2,
            child: Image.asset(
              'lib/app/shared/utils/gifs/deadBody.gif',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 23),
            child: Text(
              'No recent deaths',
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
        ),
        itemCount: player.characters?.deaths?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          return Material(
            elevation: 4,
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'DIED AT LEVEL ',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        player.characters?.deaths?[index].level.toString() ??
                            '',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        ' BY',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ImageNetwork(
                    height: 80,
                    width: 80,
                    image: player.characters?.deaths?[index].killers?[0].monster
                            ?.creature.imageUrl ??
                        '',
                  ),
                  Text(
                    player.characters?.deaths?[index].killers?[0].monster
                            ?.creature.name ??
                        '',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
