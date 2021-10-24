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

class _ZonesOverviewState extends State<ZonesOverview> {
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
            return ListZones(zones: snapshot.data!);
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
  const ListZones({Key? key, required this.zones}) : super(key: key);

  @override
  State<ListZones> createState() => _ListZonesState();
}

class _ListZonesState extends State<ListZones> {
  bool isEditingOnMobile = false;

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
    final width = MediaQuery.of(context).size.width * 0.9;
    const height = 70.0;
    List<Widget> widgets = [];
    for (var domain in domains) {
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: GestureDetector(
          onTap: () {
            showDetail(context, domain);
          },
          child: FrostedGlassBox(
              width: width,
              height: height,
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

  void isEditingOnMobileCallback() {
    print("setting that darn state");
    setState(() {
      isEditingOnMobile = true;
    });
  }

  void showDetail(BuildContext context, Domain domain) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          final size = MediaQuery.of(context).size;
          final height = getModalHeight(size);
          return Container(
              color: Colors.black12,
              height: height,
              width: size.width,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DomainForm(
                  domain,
                  isEditingCallback: isEditingOnMobileCallback,
                ),
              ));
        });
  }

  double getModalHeight(Size screenSize) {
    if (Settings.env == Environments.desktop) {
      return screenSize.height * 0.3;
    }
    if (isEditingOnMobile) {
      return screenSize.height * 0.8;
    }
    return screenSize.height * 0.3;
  }
}

class DomainForm extends StatefulWidget {
  Domain domain;
  VoidFunc? isEditingCallback;
  DomainForm(this.domain, {Key? key, this.isEditingCallback}) : super(key: key);

  @override
  _DomainFormState createState() => _DomainFormState();
}

class _DomainFormState extends State<DomainForm> {
  final _formKey = GlobalKey<FormState>();

  double getFormItemsWidth(Size size) {
    if (Settings.env == Environments.desktop) {
      return size.width * 0.5;
    }
    return size.width * 0.7;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = getFormItemsWidth(size);
    return SizedBox(
      width: width,
      height: size.height,
      child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Domain"),
                    keyboardType: TextInputType.text,
                    initialValue: widget.domain.fqdn,
                    onTap: widget.isEditingCallback,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Invalid Domain';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      setState(() {
                        widget.domain.fqdn = value!;
                      });
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "IP Address"),
                    keyboardType: TextInputType.text,
                    onTap: widget.isEditingCallback,
                    initialValue: widget.domain.ip,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Invalid IP Address';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      setState(() {
                        widget.domain.ip = value!;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(onPressed: () {}, child: Text('Delete')),
                  ElevatedButton(onPressed: () {}, child: Text('Submit')),
                ],
              ),
            ],
          )),
    );
  }
}
