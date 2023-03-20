import 'package:exiva/app/lib/app/widgets/character_detail.dart';
import 'package:exiva/app/shared/models/player.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

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
                Tab(icon: Icon(Icons.person)),
                Tab(icon: Icon(Icons.warning)),
                Tab(icon: Icon(Icons.rocket_launch_rounded)),
              ],
            ),
            title: const Text('Player'),
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(187, 148, 94, 1),
          ),
          body: TabBarView(
            children: [
              CharacterDetail(player: player),
              GridView.builder(
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
                                  player.characters?.deaths?[index].level
                                          .toString() ??
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
                              image: player.characters?.deaths?[index]
                                      .killers?[0].monster?.creature.imageUrl ??
                                  '',
                            ),
                            Text(
                              player.characters?.deaths?[index].killers?[0]
                                      .monster?.creature.name ??
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
                  }),
              const Icon(Icons.rocket_launch_rounded, size: 350),
            ],
          ),
        ),
      ),
    );
  }
}
