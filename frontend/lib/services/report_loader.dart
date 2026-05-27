import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:frontend/models/drift_report.dart';
import 'package:http/http.dart' as http;

// Small utility used by the app to obtain a `DriftReport` instance.

// During development and in the demo we use a bundled mock JSON file
// so the UI can be exercised without any network dependency.
class ReportLoader {
  // Loads the included mock report from the app's assets and
  // converts it into a `DriftReport` model.
  Future<DriftReport> loadMockReport() async {
    // Read the JSON file that was packaged with the app.
    final jsonString = await rootBundle.loadString('assets/mock_drift_report.json');
    // Decode into a Map and hand it off to the model factory.
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return DriftReport.fromJson(jsonMap);
  }

  // Fetches the report from the backend server for the live demo.
  Future<DriftReport> fetchLiveReport() async {
    final Uri url = Uri.parse('http://localhost:8080/drift_report.json');
    final http.Response response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch live report (${response.statusCode}).');
    }

    final dynamic decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Live report JSON was not an object.');
    }

    return DriftReport.fromJson(decoded);
  }
}
