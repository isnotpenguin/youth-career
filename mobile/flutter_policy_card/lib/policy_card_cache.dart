import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";
import "policy_card_model.dart";

class PolicyCardCache {
  static String _key(String id) => "policy_card:$id";

  static Future<void> put(PolicyCardData card) async {
    final prefs = await SharedPreferences.getInstance();
    final record = {
      "cachedAtISO": DateTime.now().toUtc().toIso8601String(),
      "value": card.toJson(),
    };
    await prefs.setString(_key(card.id), jsonEncode(record));
  }

  static Future<PolicyCardData?> get(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(id));
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final value = decoded["value"] as Map<String, dynamic>;
      return PolicyCardData.fromJson(value);
    } catch (_) {
      return null;
    }
  }
}

