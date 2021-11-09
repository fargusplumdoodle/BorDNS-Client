import 'package:animate_do/animate_do.dart';
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
      return Stack(children: [
        _formatBody(child: body(context)),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: notifications)
      ]);
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
      Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: notifications)
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

class ErrorNotification extends BorNotification {
  const ErrorNotification(String text, {Key? key})
      : super(
            text: text,
            color: Colors.red,
            icon: Icons.error,
            key: key,
            width: 1);
}

class SuccessNotification extends BorNotification {
  const SuccessNotification(String text, {Key? key})
      : super(text: text, color: Colors.green, icon: Icons.done, key: key);
}

class BorNotification extends StatefulWidget {
  final String text;
  final MaterialColor color;
  final IconData icon;
  final double width;

  const BorNotification({
    Key? key,
    required this.text,
    this.color = Colors.green,
    this.icon = Icons.add,
    this.width = 0.3,
  }) : super(key: key);

  @override
  _BorNotificationState createState() => _BorNotificationState();
}

class _BorNotificationState extends State<BorNotification> {
  bool expired = false;
  static const int _timeToLive = 5; // seconds

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: _timeToLive)).then((_) => {
          setState(() {
            expired = true;
          })
        });
    if (expired) {
      return Container();
    }

    return BounceInDown(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
            color: widget.color,
            width: BoxSize.varWidth(context, desktop: widget.width, mobile: 1),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(widget.icon),
                  Flexible(child: PText(widget.text)),
                ],
              ),
            )),
      ),
    );
  }
}
