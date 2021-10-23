class Model {
  Model();
  static Model fromJSON(dynamic json) {
    return Model();
  }
}

class Serializer<T extends Model> {
  List<T> many(Function fromJSON, List<dynamic> json) {
    List<T> objects = [];
    for (var element in json) {
      objects.add(fromJSON(element));
    }
    return objects;
  }
}

class Domain implements Model {
  String ip;
  String fqdn;

  Domain({required this.ip, required this.fqdn});

  static Domain fromJSON(dynamic json) {
    return Domain(ip: json['ip'], fqdn: json['fqdn']);
  }

  @override
  String toString() {
    return "$fqdn: $ip";
  }
}

class Zone implements Model {
  final String name;
  List<Domain> domains;

  Zone({required this.name, required this.domains});

  static Zone fromJSON(dynamic json) {
    final s = Serializer<Domain>();
    return Zone(
        name: json['zone'], domains: s.many(Domain.fromJSON, json['domains']));
  }

  @override
  String toString() {
    return name;
  }
}
