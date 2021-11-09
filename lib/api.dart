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
  @override
  String toString() {
    return message;
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

  dynamic _processResponse({
    required http.Response r,
    required String endpoint,
    required Map<String, String>? qs,
    required String method,
    required int expectedResponse,
    required bool decode,
  }) {
    if (r.statusCode != expectedResponse) {
      throw APIException(
          message: "Failed to make API request: ${r.body}",
          endpoint: endpoint,
          method: method,
          qs: qs,
          response: r);
    }
    developer.log(method, error: {
      "status": r.statusCode,
      "body": r.body,
      "qs": qs,
      "endpoint": endpoint
    });
    if (decode) {
      return jsonDecode(r.body);
    }
    return r.body;
  }

  Future<dynamic> _get(String endpoint, {Map<String, String>? qs}) async {
    http.Response r =
        await http.get(_getURI(endpoint, qs), headers: _getHeaders());
    return _processResponse(
      decode: true,
      r: r,
      endpoint: endpoint,
      qs: qs,
      method: "get",
      expectedResponse: 200,
    );
  }

  Future<dynamic> _post(String endpoint, {Map<String, String>? qs}) async {
    http.Response r =
        await http.post(_getURI(endpoint, qs), headers: _getHeaders());

    return _processResponse(
      decode: true,
      r: r,
      endpoint: endpoint,
      qs: qs,
      method: "post",
      expectedResponse: 201,
    );
  }

  Future<dynamic> _delete(String endpoint, {Map<String, String>? qs}) async {
    http.Response r =
        await http.delete(_getURI(endpoint, qs), headers: _getHeaders());

    return _processResponse(
      r: r,
      endpoint: endpoint,
      qs: qs,
      method: "delete",
      expectedResponse: 201,
      decode: false,
    );
  }
}

class BorDnsAPI extends API {
  Future<List<Zone>> list() async {
    final data = await super._get("domain");
    return Serializer<Zone>().many(Zone.fromJSON, data);
  }

  Future<Domain> set({required Domain domain, required Domain old}) async {
    if (old.fqdn != '') {
      await super._delete("fqdn", qs: {'FQDN': old.fqdn});
    }
    final data = await super._post(
      "fqdn",
      qs: {'FQDN': domain.fqdn, 'IP': domain.ip},
    );
    return Domain.fromJSON(data);
  }

  Future<void> delete(Domain domain) async {
    await super._delete("fqdn", qs: {'FQDN': domain.fqdn});
  }
}
