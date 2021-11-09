import 'package:flutter/material.dart';

import '../settings.dart';
import 'utils.dart';

mixin Base<T extends StatefulWidget> on State<T> {
  final List<BorNotification> notifications = [];

  double menuWidthPercent = 0.2;
  final List<String> menuItems = [];

  // OVERWRITE THESE
  body(BuildContext context) {}
  floatingActionButton(BuildContext context) {}

  // BASE METHODS
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: _buildBody(context),
      floatingActionButton: floatingActionButton(context),
      drawer: _getDrawer(),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (Settings.env == Environments.mobile) {
      return _formatBody(child: body(context));
    }
    var size = MediaQuery.of(context).size;
    final menuWidth = size.width * menuWidthPercent;
    final bodyWidth = size.width - menuWidth;

    return Stack(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SizedBox(width: menuWidth, height: size.height, child: _getMenu()),
        _formatBody(
            child: SizedBox(
                width: bodyWidth, height: size.height, child: body(context)))
      ]),
      ..._getNotifications(context)
    ]);
  }

  Widget _formatBody({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: Image.asset(img('blue.png')).image, fit: BoxFit.cover)),
      child: child,
    );
  }

  AppBar _getAppBar() {
    return AppBar(
      title: const Text("BorDNS"),
    );
  }

  Widget? _getDrawer() {
    if (Settings.env == Environments.mobile) {
      return Drawer(
        child: _getMenu(),
      );
    }
    return null;
  }

  // NOTIFICATIONS
  void addNotification(BorNotification notification) {
    setState(() {
      notifications.add(notification);
    });
  }

  List<Widget> _getNotifications(BuildContext context) {
    // Removes expired notifications from list
    List<Widget> widgets = [];
    // TODO: REMOVE EXPIRED NOTIFICATIONS
    for (var notification in notifications) {
      if (!notification.expired) {
        widgets.add(notification.build(context));
      }
    }
    return widgets;
  }

  // MENU
  Widget _getMenu() {
    return Container(
      color: const Color(0x00161616),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: _buildMenuItems(),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    List<Widget> widgets = [];
    for (var item in menuItems) {
      widgets.add(ListTile(
        title: Text(item.toUpperCase()),
      ));
    }
    return widgets;
  }
}

/*

class Screen {
  Widget body;
  BuildContext context;

  Key? key;
  PreferredSizeWidget? appBar;
  Widget? floatingActionButton;
  Widget? drawer;
  late Widget _body;

  List<Notification> notifications = [];

  Menu? menu;
  List<String> menuItems;
  double menuWidthPercent = 0.2;

  Screen({
    required this.body,
    required this.context,
    required this.menuItems,
    required this.notifications,
    Key? key,
    this.appBar,
    this.floatingActionButton,
  }) {
    menu = Menu(items: menuItems);
    appBar ??= getAppBar();
    _body = buildBody();
    drawer = buildDrawer();
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

    return Stack(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(width: menuWidth, height: size.height, child: menu!),
          Body(
              child:
                  SizedBox(width: bodyWidth, height: size.height, child: body))
        ]),
        BorNotification(),
      ],
    );
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

 */
class Header extends Text {
  const Header(String data, {Key? key})
      : super(data,
            key: key,
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold));
}

class PText extends Text {
  const PText(String data, {Key? key})
      : super(data,
            key: key,
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 20));
}

typedef VoidFunc = void Function();

class BoxSize {
  static double _getModifier({double? base, double? desktop, double? mobile}) {
    if (desktop == null && mobile == null && base == null) {
      return 1.0;
    }
    if (base != null) {
      return base;
    }
    if (Settings.env == Environments.desktop) {
      if (desktop == null) {
        return 1;
      }
      return desktop;
    } else {
      if (mobile == null) {
        return 1;
      }
      return mobile;
    }
  }

  static double varHeight(BuildContext context,
      {double? base, double? desktop, double? mobile}) {
    final size = MediaQuery.of(context).size;
    return size.height *
        _getModifier(
          base: base,
          desktop: desktop,
          mobile: mobile,
        );
  }

  static double varWidth(BuildContext context,
      {double? base, double? desktop, double? mobile}) {
    final size = MediaQuery.of(context).size;
    return size.width *
        _getModifier(
          base: base,
          desktop: desktop,
          mobile: mobile,
        );
  }

  static double staticVal({double? base, double? desktop, double? mobile}) {
    assert(base != null || desktop != null || mobile != null);
    return _getModifier(
      base: base,
      desktop: desktop,
      mobile: mobile,
    );
  }
}

class BorNotification {
  // TODO KEEP TRACK OF TIME IN EXISTENCE, SET EXPIRED
  bool expired = false;
  final String text;

  BorNotification(this.text);

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
          color: Colors.green,
          child: Row(
            children: [
              const Icon(Icons.add),
              Text(text),
            ],
          )),
    );
  }
}
