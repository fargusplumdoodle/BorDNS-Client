import '../settings.dart';

String img(String name, {platformDependant = false}) {
  String path = "assets/";
  if (!platformDependant) {
    path += name;
  } else if (Settings.env == Environments.mobile) {
    path += "desktop/$name";
  } else {
    path += "mobile/$name";
  }
  return path;
}
