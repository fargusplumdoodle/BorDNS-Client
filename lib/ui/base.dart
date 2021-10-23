import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../settings.dart';
import 'utils.dart';

class Menu extends StatelessWidget {
  final Map<String, String> items;

  const Menu({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x00161616),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _getDrawerLinks(context),
        ),
      ),
    );
  }

  List<Widget> _getDrawerLinks(BuildContext context) {
    List<Widget> links = [];
    items.forEach((key, value) => links.add(ListTile(
          title: Text(key),
          onTap: () {
            SchedulerBinding.instance!.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, value);
            });
          },
        )));
    return links;
  }
}

class Body extends StatelessWidget {
  final Widget child;

  const Body({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: Image.asset(img('background.png', platformDependant: true))
                  .image,
              fit: BoxFit.cover)),
      child: child,
    );
  }
}

class TestScaffold {
  Widget body;
  BuildContext context;

  Key? key;
  PreferredSizeWidget? appBar;
  Widget? floatingActionButton;
  Widget? drawer;
  late Widget _body;

  Menu? menu;
  double menuWidthPercent = 0.2;

  TestScaffold({
    required this.body,
    required this.context,
    Key? key,
    this.appBar,
    this.floatingActionButton,
  }) {
    menu = buildMenu();
    appBar ??= getAppBar();
    _body = buildBody();
    drawer = buildDrawer();
  }

  Menu buildMenu() {
    return Menu(items: routes);
  }

  Scaffold get() {
    return Scaffold(
        appBar: appBar,
        body: _body,
        floatingActionButton: floatingActionButton,
        drawer: drawer);
  }

  AppBar getAppBar() {
    return AppBar(
      title: const Text("BorDNS"),
    );
  }

  Widget buildBody() {
    if (Settings.env == Environments.mobile) {
      return Body(child: body);
    }
    var size = MediaQuery.of(context).size;
    final menuWidth = size.width * menuWidthPercent;
    final bodyWidth = size.width - menuWidth;

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(width: menuWidth, height: size.height, child: menu!),
      Body(child: SizedBox(width: bodyWidth, height: size.height, child: body))
    ]);
  }

  Widget? buildDrawer() {
    if (Settings.env == Environments.mobile) {
      return Drawer(
        child: menu,
      );
    }
    return null;
  }
}
