import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _dnsKey = 'selected_dns_ip';
  static const _mtuKey = 'mtu_size';
  static const _keepaliveKey = 'keepalive_interval';
  static const _lanBypassKey = 'lan_bypass';
  static const _streamingBypassKey = 'streaming_bypass';
  static const _debugModeKey = 'debug_mode';

  // --- Mevcut Metotlar ---
  Future<String> getDns() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dnsKey) ?? '94.140.14.14, 94.140.15.15';
  }

  Future<void> setDns(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dnsKey, ip);
  }

  Future<int> getMtu() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_mtuKey) ?? 1420;
  }

  Future<void> setMtu(int mtu) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_mtuKey, mtu);
  }

  Future<int> getKeepalive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keepaliveKey) ?? 25;
  }

  Future<void> setKeepalive(int keepalive) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keepaliveKey, keepalive);
  }

  // --- Yeni Gündelik Hayat & Geliştirici Metotları ---
  Future<bool> getLanBypass() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_lanBypassKey) ?? false;
  }

  Future<void> setLanBypass(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lanBypassKey, value);
  }

  Future<bool> getStreamingBypass() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_streamingBypassKey) ?? false;
  }

  Future<void> setStreamingBypass(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_streamingBypassKey, value);
  }

  Future<bool> getDebugMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_debugModeKey) ?? false;
  }

  Future<void> setDebugMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_debugModeKey, value);
  }
}
