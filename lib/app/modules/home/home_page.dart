import 'package:exiva/app/shared/models/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_triple/flutter_triple.dart';
import '../../shared/utils/images/randomize_image.dart';
import 'home_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeStore store;

  @override
  void initState() {
    super.initState();
    store = Modular.get<HomeStore>();
  }

  @override
  void dispose() {
    Modular.dispose<HomeStore>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(77, 78, 80, 1),
      body: ScopedBuilder<HomeStore, Exception, Player>(
        store: store,
        onState: (_, player) {
          return Stack(
            children: [
              Image.asset(
                RandomBackgroundImage.getBackgroundImageName(),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SizedBox(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Find a character:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 53,
                                  fontFamily: 'PentaRounded',
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      offset: Offset(2, 2),
                                      blurRadius: 4,
                                    )
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        bottomLeft: Radius.circular(5)),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.06,
                                      width: MediaQuery.of(context).size.width *
                                          0.23,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: TextFormField(
                                          controller: store.textController,
                                          keyboardType: TextInputType.text,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          autofocus: true,
                                          cursorColor: const Color.fromRGBO(
                                              88, 101, 241, 1),
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Character name',
                                            hintStyle: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade500,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    width: MediaQuery.of(context).size.width *
                                        0.05,
                                    child: TextButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          const Color.fromRGBO(88, 101, 241, 1),
                                        ),
                                      ),
                                      child: const Text(
                                        'Exiva!',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () {
                                        store.getPlayer(
                                            store.textController.text);
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(
                        child: SizedBox(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        onError: (context, error) => const CircularProgressIndicator(),
        onLoading: (context) => const CircularProgressIndicator(),
      ),
    );
  }
}
