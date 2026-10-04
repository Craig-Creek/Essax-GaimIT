import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/essay.dart';

class EssayStorage {
  static const _key = 'essax_essays';

  Future<List<Essay>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Essay.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<Essay> essays) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(essays.map((e) => e.toJson()).toList()),
    );
  }
}
