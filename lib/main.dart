import 'package:bordns_client/api.dart';
import 'package:bordns_client/screens/list.dart';
import 'package:flutter/material.dart';

import 'ui/ui.dart';

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
        home: const MainScreen());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      context: context,
      body: Center(
        child: FrostedGlassBox(
            height: 200,
            width: 500,
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      final api = BorDnsAPI();
                      api.list();
                    },
                    child: const Text("Make API call")),
                Text("Ah: $_counter"),
              ],
            ))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    ).get();
  }
}
