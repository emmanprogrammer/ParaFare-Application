import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:parafare_application/mvp/models.dart';

class MvpLocalStore {
  MvpLocalStore(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'mvp_app_data_v1';

  Future<MvpAppData> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const MvpAppData(onboardingComplete: false);
    }

    return MvpAppData.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<void> save(MvpAppData data) async {
    await _prefs.setString(_key, jsonEncode(data.toJson()));
  }
}
