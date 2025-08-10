import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageServiceReport {
  static const String _storageKey = 'savedReports';

  // Save data
  Future<void> saveReport(Map<String, String> report) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> reports = prefs.getStringList(_storageKey) ?? [];
    reports.add(jsonEncode(report)); // Convert to JSON string and store
    await prefs.setStringList(_storageKey, reports);
  }

  // Retrieve all saved reports
  Future<List<Map<String, String>>> getReports() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> reports = prefs.getStringList(_storageKey) ?? [];
    return reports.map((e) => Map<String, String>.from(jsonDecode(e))).toList();
  }

  Future<void> clearReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
