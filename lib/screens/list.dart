import 'package:bordns_client/ui/ui.dart';
import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';

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
            return const Text('some error ill figure out how to display later');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

class ListZones extends StatelessWidget {
  final List<Zone> zones;
  const ListZones({Key? key, required this.zones}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    for (var zone in zones) {
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
      ));
    }

    return widgets;
  }
}
