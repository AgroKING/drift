import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:frontend/models/drift_report.dart';

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

  // In a real app, this would make a network request to fetch the latest report data.
  Future<DriftReport> fetchLiveReport() async {
    throw UnimplementedError('Live report fetching will be implemented for the demo.');
  }
}
