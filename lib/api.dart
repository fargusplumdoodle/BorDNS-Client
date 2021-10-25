import 'dart:convert';
import 'dart:developer' as developer;

import 'package:bordns_client/settings.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

class APIException {
  final String message;
  final String method;
  final String endpoint;
  final Map<String, String>? qs;
  final http.Response response;

  APIException(
      {required this.message,
      required this.method,
      required this.endpoint,
      required this.response,
      this.qs}) {
    developer.log(message, level: 0, error: {
      "status": response.statusCode,
      "body": response.body,
      "method": method,
      "qs": qs,
      "endpoint": endpoint
    });
  }
}

abstract class API {
  Map<String, String> _getHeaders() {
    final bytes = utf8.encode("${Settings.username}:${Settings.password}");
    final authString = base64.encode(bytes);
    return {
      "Content-Type": "application/json",
      "Authorization": 'Basic $authString',
    };
  }

  Uri _getURI(String endpoint, Map<String, String>? qs) {
    return Uri.http(Settings.apiHost, endpoint, qs);
  }

  Future<dynamic> _get(String endpoint, {Map<String, String>? qs}) async {
    http.Response r =
        await http.get(_getURI(endpoint, qs), headers: _getHeaders());

    if (r.statusCode != 200) {
      throw APIException(
          message: "Failed to make API request",
          endpoint: endpoint,
          method: 'get',
          qs: qs,
          response: r);
    }
    developer.log("get", error: {
      "status": r.statusCode,
      "body": r.body,
      "qs": qs,
      "endpoint": endpoint
    });
    return jsonDecode(r.body);
  }

  Future<dynamic> _post(String endpoint, {Map<String, String>? qs}) async {
    http.Response r =
        await http.post(_getURI(endpoint, qs), headers: _getHeaders());

    if (r.statusCode != 201) {
      throw APIException(
          message: "Failed to make API request",
          endpoint: endpoint,
          method: 'post',
          qs: qs,
          response: r);
    }
    developer.log("post", error: {
      "status": r.statusCode,
      "body": r.body,
      "qs": qs,
      "endpoint": endpoint
    });
    return jsonDecode(r.body);
  }
}

class BorDnsAPI extends API {
  Future<List<Zone>> list() async {
    final data = await super._get("domain");
    return Serializer<Zone>().many(Zone.fromJSON, data);
  }

  Future<Domain> set(Domain domain) async {
    final data = await super._post(
      "fqdn",
      qs: {'FQDN': domain.fqdn, 'IP': domain.ip},
    );
    return Domain.fromJSON(data);
  }
}
