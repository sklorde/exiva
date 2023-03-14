import 'dart:math';

class RandomBackgroundImage {
  static String getBackgroundImageName() {
    Random random = Random();
    int randomNumber = random.nextInt(2) + 1;
    String backgroundImageName =
        "lib/app/shared/utils/images/backgroundHomePage$randomNumber.jpg";
    return backgroundImageName;
  }
}
