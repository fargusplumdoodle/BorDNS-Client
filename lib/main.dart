import 'package:bordns_client/screens/list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        fontFamily: 'Ubuntu',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Ubuntu',
      ),
      themeMode: ThemeMode.dark,
      initialRoute: MainScreen.route,
      routes: {MainScreen.route: (context) => const MainScreen()},
    );
  }
}
