import 'package:bordns_client/ui/forms.dart';
import 'package:bordns_client/ui/ui.dart';
import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../settings.dart';

typedef DetailCallback = void Function(
  BuildContext context,
  Domain domain,
  bool edit,
);
typedef DomainDeleteCallback = Future<void> Function(Domain domain);
typedef DomainSubmitCallback = Future<void> Function(
    {required Domain domain, required Domain old});
typedef DeleteCallback = Future<bool> Function(Domain domain);

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static String route = '/';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with Base<MainScreen> {
  bool loading = false;
  late Future<List<Zone>> _futureZones;
  List<Zone>? _zones;

  @override
  void initState() {
    super.initState();
    _futureZones = fetchZones();
  }

  Future<List<Zone>> fetchZones() async {
    final zones = await BorDnsAPI().list();
    setState(() {
      _zones = zones;
    });
    return zones;
  }

  @override
  FloatingActionButton floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        showDetailCallback(context, Domain(fqdn: "", ip: ""), false);
      },
    );
  }

  @override
  Widget body(BuildContext context) {
    menuItems.clear();
    if (_zones != null) {
      menuItems.clear();
      setState(() {
        for (var element in _zones!) {
          menuItems.add(element.name);
        }
      });
    }
    return FutureBuilder<List<Zone>>(
        future: _futureZones,
        builder: (BuildContext context, AsyncSnapshot<List<Zone>> snapshot) {
          if (snapshot.hasData) {
            return ListZones(
              zones: _zones!,
              detailCallback: showDetailCallback,
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Future<void> submitCallback(
      {required Domain domain, required Domain old}) async {
    BorDnsAPI().set(domain: domain, old: old).then((_) {
      setState(() {
        _futureZones = fetchZones();
      });
      addNotification(const SuccessNotification("Updated"));
    }).catchError((err) {
      addNotification(ErrorNotification(err.toString()));
    });
  }

  Future<void> deleteCallback(Domain domain) async {
    await BorDnsAPI().delete(domain).then((value) {
      setState(() {
        _futureZones = fetchZones();
      });
      addNotification(const SuccessNotification("Deleted"));
    }).catchError((err) {
      addNotification(ErrorNotification(err.toString()));
    });
  }

  void showDetailCallback(BuildContext context, Domain domain, bool edit) {
    if (Settings.env == Environments.desktop) {
      showDetailDesktop(context, domain, edit);
    } else {
      showDetailMobile(context, domain, edit);
    }
  }

  void showDetailDesktop(BuildContext context, Domain domain, bool edit) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: BoxSize.varHeight(context, desktop: 0.31),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildForm(domain, edit),
            ),
          );
        });
  }

  void showDetailMobile(BuildContext context, Domain domain, bool edit) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 190,
              width: BoxSize.varWidth(context, mobile: 0.9),
              child: _buildForm(domain, edit),
            ),
          );
        });
  }

  Widget _buildForm(Domain domain, bool edit) {
    return DomainForm(
      domain,
      submitCallback: submitCallback,
      deleteCallback: deleteCallback,
      edit: edit,
    );
  }
}

class ListZones extends StatefulWidget {
  final List<Zone> zones;
  final DetailCallback detailCallback;
  const ListZones({Key? key, required this.zones, required this.detailCallback})
      : super(key: key);

  @override
  State<ListZones> createState() => _ListZonesState();
}

class _ListZonesState extends State<ListZones> {
  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    for (var zone in widget.zones) {
      widgets.add(Padding(
        padding: const EdgeInsets.all(16.0),
        child: Header(zone.name),
      ));
      widgets.addAll(_buildDomainList(context, zone.domains));
    }
    return ListView(children: widgets);
  }

  List<Widget> _buildDomainList(BuildContext context, List<Domain> domains) {
    List<Widget> widgets = [];
    for (var domain in domains) {
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: GestureDetector(
          onTap: () {
            widget.detailCallback(context, domain, true);
          },
          child: FrostedGlassBox(
              width: BoxSize.varWidth(context, base: 0.9),
              height: 70.0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      PText(domain.fqdn),
                      PText(domain.ip),
                    ],
                  ),
                ),
              )),
        ),
      ));
    }
    return widgets;
  }
}

class DomainForm extends StatefulWidget {
  final Domain domain;
  final DomainSubmitCallback submitCallback;
  final DomainDeleteCallback deleteCallback;
  final bool edit;
  const DomainForm(this.domain,
      {Key? key,
      required this.submitCallback,
      required this.deleteCallback,
      required this.edit})
      : super(key: key);

  @override
  _DomainFormState createState() => _DomainFormState();
}

class _DomainFormState extends State<DomainForm> {
  final _formKey = GlobalKey<FormState>();
  late final _formDomain = Domain(
    ip: widget.domain.ip,
    fqdn: widget.domain.fqdn,
  );

  @override
  void initState() {
    super.initState();
  }

  void submit(context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    widget.submitCallback(domain: _formDomain, old: widget.domain).then((_) {
      Navigator.of(context).pop();
    });
  }

  void delete(context) {
    widget.deleteCallback(widget.domain).then((_) {
      Navigator.of(context).pop();
    });
  }

  Widget _buildButtonRow(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      GlassButton(
          onTap: () {
            submit(context);
          },
          child: const Text('Submit')),
      const Padding(padding: EdgeInsets.all(8.0)),
      GlassButton(
          onTap: () {
            delete(context);
          },
          red: true,
          disabled: !widget.edit,
          child: const Text('Delete')),
    ]);
  }

  Form _buildForm() {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: BoxSize.varWidth(context, desktop: 0.5, mobile: 0.7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DomainFormField(
                      initialValue: widget.domain.fqdn,
                      onSaved: (value) {
                        setState(() {
                          _formDomain.fqdn = value!;
                        });
                      }),
                  IPFormField(
                      initialValue: widget.domain.ip,
                      onSaved: (value) {
                        setState(() {
                          _formDomain.ip = value!;
                        });
                      }),
                ],
              ),
            ),
            _buildButtonRow(context)
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return _buildForm();
  }
}
