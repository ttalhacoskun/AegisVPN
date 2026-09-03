import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/settings_service.dart';

class SettingsViewModel extends ChangeNotifier {
  late final SettingsService _settingsService;

  String selectedDnsIp = '94.140.14.14, 94.140.15.15';
  int mtuSize = 1420;
  int keepaliveSecs = 25;

  bool allowLan = false;
  bool bypassStreaming = false;
  bool debugMode = false;

  SettingsViewModel({SettingsService? settingsService})
    : _settingsService = settingsService ?? SettingsService() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    selectedDnsIp = await _settingsService.getDns();
    mtuSize = await _settingsService.getMtu();
    keepaliveSecs = await _settingsService.getKeepalive();
    allowLan = await _settingsService.getLanBypass();
    bypassStreaming = await _settingsService.getStreamingBypass();
    debugMode = await _settingsService.getDebugMode();
    notifyListeners();
  }

  Future<void> setDns(String ip) async {
    HapticFeedback.lightImpact();
    selectedDnsIp = ip;
    await _settingsService.setDns(ip);
    notifyListeners();
  }

  Future<void> setMtu(int val) async {
    mtuSize = val;
    await _settingsService.setMtu(val);
    notifyListeners();
  }

  Future<void> setMtuFinished() async {
    HapticFeedback.selectionClick();
  }

  Future<void> setKeepalive(int secs) async {
    HapticFeedback.lightImpact();
    keepaliveSecs = secs;
    await _settingsService.setKeepalive(secs);
    notifyListeners();
  }

  Future<void> toggleLanBypass(bool val) async {
    HapticFeedback.lightImpact();
    allowLan = val;
    await _settingsService.setLanBypass(val);
    notifyListeners();
  }

  Future<void> toggleStreamingBypass(bool val) async {
    HapticFeedback.lightImpact();
    bypassStreaming = val;
    await _settingsService.setStreamingBypass(val);
    notifyListeners();
  }

  Future<void> toggleDebugMode(bool val) async {
    HapticFeedback.lightImpact();
    debugMode = val;
    await _settingsService.setDebugMode(val);
    notifyListeners();
  }
}
