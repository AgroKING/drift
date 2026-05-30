import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:drift/models/drift_report.dart';
import 'package:http/http.dart' as http;

class ReportLoader {
  static const String _liveReportUrl =
      'http://localhost:8080/drift_report.json';

  Future<DriftReport> loadMockReport() async {
    final jsonString = await rootBundle.loadString(
      'assets/mock_drift_report.json',
    );
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return DriftReport.fromJson(jsonMap);
  }

  Future<DriftReport> fetchLiveReport() async {
    final Uri url = Uri.parse(_liveReportUrl);

    final http.Response response;
    try {
      response = await http.get(url);
    } on http.ClientException {
      throw Exception(
        'Could not reach the report server at $_liveReportUrl.\n'
        'Make sure the backend report is generated and the server is running:\n'
        '  ./scripts/serve_report.sh',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Report server returned HTTP ${response.statusCode} '
        '(expected 200).',
      );
    }

    final dynamic decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Live report JSON was not an object.');
    }

    return DriftReport.fromJson(decoded);
  }
}
