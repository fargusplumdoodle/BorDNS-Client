import 'package:bordns_client/ui/forms.dart';
import 'package:bordns_client/ui/ui.dart';
import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../settings.dart';

class ZonesOverview extends StatefulWidget {
  const ZonesOverview({Key? key}) : super(key: key);

  @override
  _ZonesOverviewState createState() => _ZonesOverviewState();
}

class _ZonesOverviewState extends State<ZonesOverview> with DomainDetail {
  bool loading = false;
  late Future<List<Zone>> zones;

  @override
  void initState() {
    super.initState();
    zones = fetchZones();
  }

  Future<List<Zone>> fetchZones() async {
    final api = BorDnsAPI();
    return await api.list();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(context: context, body: getBody(context)).get();
  }

  Widget getBody(BuildContext context) {
    return FutureBuilder<List<Zone>>(
        future: zones,
        builder: (BuildContext context, AsyncSnapshot<List<Zone>> snapshot) {
          if (snapshot.hasData) {
            return ListZones(
              zones: snapshot.data!,
              detailCallback: super.showDetailCallback,
            );
          } else if (snapshot.hasError) {
            // TODO: GLOBAL ERRORS PLACE FOR ERRORS AND ERRORS
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
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
            widget.detailCallback(context, domain);
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

typedef DetailCallback = void Function(BuildContext context, Domain domain);
typedef DomainCallback = Future<void> Function(Domain domain);
typedef DeleteCallback = Future<bool> Function(Domain domain);

mixin DomainDetail on State<ZonesOverview> {
  Future<void> submitCallback(Domain domain) async {
    BorDnsAPI().set(domain);
  }

  Future<bool> deleteCallback(Domain domain) async {
    print('waiting');
    await Future.delayed(const Duration(seconds: 3));
    print('done');
    return true;
  }

  void showDetailCallback(BuildContext context, Domain domain) {
    if (Settings.env == Environments.desktop) {
      showDetailDesktop(context, domain);
    } else {
      showDetailMobile(context, domain);
    }
  }

  void showDetailDesktop(BuildContext context, Domain domain) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: BoxSize.varHeight(context, desktop: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildForm(domain),
            ),
          );
        });
  }

  void showDetailMobile(BuildContext context, Domain domain) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 190,
              child: _buildForm(domain),
            ),
          );
        });
  }

  Widget _buildForm(Domain domain) {
    return DomainForm(
      domain,
      submitCallback: submitCallback,
      deleteCallback: deleteCallback,
    );
  }
}

class DomainForm extends StatefulWidget {
  final Domain domain;
  final DomainCallback submitCallback;
  final DeleteCallback deleteCallback;
  const DomainForm(this.domain,
      {Key? key, required this.submitCallback, required this.deleteCallback})
      : super(key: key);

  @override
  _DomainFormState createState() => _DomainFormState();
}

class _DomainFormState extends State<DomainForm> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  void _makeAPICall(DomainCallback callback) async {
    setState(() {
      _loading = true;
    });
    callback(widget.domain).then((v) {
      setState(() {
        _loading = false;
      });
    });
  }

  void submit() async {
    _makeAPICall(widget.submitCallback);
  }

  void delete() async {
    _makeAPICall(widget.deleteCallback);
  }

  Widget? _buildDesktopLoadingIndicator() {
    if (Settings.env == Environments.mobile || !_loading) {
      return null;
    }
    return const Expanded(child: Center(child: CircularProgressIndicator()));
  }

  Widget? _buildMobileLoadingIndicator() {
    if (Settings.env == Environments.desktop || !_loading) {
      return null;
    }
    return const CircularProgressIndicator();
  }

  Widget _buildButtonRow() {
    List<Widget> widgets = [
      GlassButton(onTap: submit, child: const Text('Submit')),
      const Padding(padding: EdgeInsets.all(8.0)),
      GlassButton(onTap: delete, red: true, child: const Text('Delete')),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 30.0)),
    ];
    final loadingIndicator = _buildMobileLoadingIndicator();
    if (loadingIndicator != null) {
      widgets.add(loadingIndicator);
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: widgets);
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
                          widget.domain.fqdn = value!;
                        });
                      }),
                  IPFormField(
                      initialValue: widget.domain.ip,
                      onSaved: (value) {
                        setState(() {
                          widget.domain.ip = value!;
                        });
                      }),
                ],
              ),
            ),
            _buildButtonRow()
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [_buildForm()];
    var loadingIndicator = _buildDesktopLoadingIndicator();
    if (loadingIndicator != null) {
      widgets.add(loadingIndicator);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: widgets,
    );
  }
}
