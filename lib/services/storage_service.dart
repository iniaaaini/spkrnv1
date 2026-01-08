// services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _productionRecordsKey = 'production_records';

  Future<void> saveProductionRecords(List<Map<String, dynamic>> records) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(records.map((record) {
        // Convert DateTime to String
        final convertedRecord = Map<String, dynamic>.from(record);
        if (record['date'] is DateTime) {
          convertedRecord['date'] = record['date'].toIso8601String();
        }
        return convertedRecord;
      }).toList());
      
      await prefs.setString(_productionRecordsKey, encodedData);
      print('✅ Data berhasil disimpan: ${records.length} records');
    } catch (e) {
      print('❌ Error menyimpan data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> loadProductionRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encodedData = prefs.getString(_productionRecordsKey);
      
      if (encodedData != null) {
        final List<dynamic> decodedData = jsonDecode(encodedData);
        final List<Map<String, dynamic>> records = decodedData.map((item) {
          final record = Map<String, dynamic>.from(item);
          // Convert String back to DateTime
          if (record['date'] is String) {
            record['date'] = DateTime.parse(record['date']);
          }
          return record;
        }).toList();
        
        print('✅ Data berhasil dimuat: ${records.length} records');
        return records;
      }
    } catch (e) {
      print('❌ Error memuat data: $e');
    }
    
    return [];
  }

  Future<void> clearProductionRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_productionRecordsKey);
      print('✅ Data berhasil dihapus');
    } catch (e) {
      print('❌ Error menghapus data: $e');
    }
  }
}