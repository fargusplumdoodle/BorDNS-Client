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
typedef DomainCallback = Future<void> Function(Domain domain);
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

class _MainScreenState extends State<MainScreen> {
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
  Widget build(BuildContext context) {
    List<String> menuItems = [];
    if (_zones != null) {
      for (var element in _zones!) {
        menuItems.add(element.name);
      }
    }
    return Screen(
      context: context,
      body: getBody(context),
      menuItems: menuItems,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDetailCallback(context, Domain(fqdn: "", ip: ""), false);
        },
      ),
    ).get();
  }

  Widget getBody(BuildContext context) {
    return FutureBuilder<List<Zone>>(
        future: _futureZones,
        builder: (BuildContext context, AsyncSnapshot<List<Zone>> snapshot) {
          if (snapshot.hasData) {
            return ListZones(
              zones: _zones!,
              detailCallback: showDetailCallback,
            );
          } else if (snapshot.hasError) {
            // TODO: GLOBAL ERRORS PLACE FOR ERRORS AND ERRORS
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Future<void> submitCallback(Domain domain) async {
    BorDnsAPI().set(domain).then((value) {
      setState(() {
        _futureZones = fetchZones();
      });
    });
  }

  Future<void> deleteCallback(Domain domain) async {
    await BorDnsAPI().delete(domain).then((value) {
      setState(() {
        _futureZones = fetchZones();
      });
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
  final DomainCallback submitCallback;
  final DomainCallback deleteCallback;
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
  bool _loading = false;
  late final _formDomain = Domain(
    ip: widget.domain.ip,
    fqdn: widget.domain.fqdn,
  );

  @override
  void initState() {
    super.initState();
  }

  Future<void> _makeAPICall(Domain domain, DomainCallback callback) async {
    setState(() {
      _loading = true;
    });
    callback(domain);
  }

  void submit(context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    if (widget.edit) {
      _makeAPICall(widget.domain, widget.deleteCallback);
    }
    _makeAPICall(_formDomain, widget.submitCallback).then((_) {
      Navigator.of(context).pop();
    });
  }

  void delete(context) {
    _makeAPICall(widget.domain, widget.deleteCallback).then((_) {
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
