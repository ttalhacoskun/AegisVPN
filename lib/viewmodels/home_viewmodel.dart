import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';

import '../models/server_list.dart';
import '../models/server_location.dart';
import '../services/settings_service.dart';
import '../services/vpn_service.dart';

class HomeViewModel extends ChangeNotifier {
  late final VpnService _vpnService;
  late final SettingsService _settingsService;

  bool isConnected = false;
  bool isConnecting = false;

  late ServerLocation activeServer;

  // Metrikler
  int secondsElapsed = 0;
  double downSpeed = 0.0;
  double upSpeed = 0.0;
  int currentPing = 0;
  double totalRxBytes = 0.0;
  double totalTxBytes = 0.0;
  int actualBlockedAds = 0;

  Timer? _sessionTimer;
  StreamSubscription<VpnStage>? _vpnSubscription;

  HomeViewModel({VpnService? vpnService, SettingsService? settingsService})
    : _vpnService = vpnService ?? VpnService(),
      _settingsService = settingsService ?? SettingsService() {
    // Varsayılan sunucuyu listemizden alıyoruz
    activeServer = ServerList.allServers.first;
    currentPing = activeServer.latencyMs;
    _initVpn();
  }

  Future<void> _initVpn() async {
    try {
      await _vpnService.initialize();
      _vpnSubscription = _vpnService.vpnStageStream.listen((stage) {
        if (stage == VpnStage.connected) {
          isConnected = true;
          isConnecting = false;
          _startLiveMetrics();
        } else if (stage == VpnStage.disconnected) {
          isConnected = false;
          isConnecting = false;
          _stopLiveMetrics();
        } else if (stage == VpnStage.connecting ||
            stage == VpnStage.preparing) {
          isConnecting = true;
        }
        notifyListeners();
      });
    } catch (e) {
      debugPrint('WireGuard init hatası: $e');
    }
  }

  // Kullanıcı farklı sunucu seçtiğinde çalışacak
  void changeServer(ServerLocation newServer) {
    activeServer = newServer;
    currentPing = newServer.latencyMs;
    notifyListeners();
  }

  // Sadece mantığı işler, BuildContext (UI) burada olmaz. Hata varsa string döndürür.
  Future<String?> toggleVPN() async {
    if (isConnecting) return null;

    isConnecting = true;
    notifyListeners();

    try {
      if (isConnected) {
        await _vpnService.stopVpn();
        return null;
      } else {
        final config = await _buildQuickConfig();
        await _vpnService.startVpn(
          '${activeServer.ip}:${activeServer.port}',
          config,
        );
        return null;
      }
    } catch (e) {
      debugPrint('VPN hatası: $e');
      isConnecting = false;
      isConnected = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<String> _buildQuickConfig() async {
    final dns = await _settingsService.getDns();
    final mtu = await _settingsService.getMtu();
    final keepalive = await _settingsService.getKeepalive();
    final allowLan = await _settingsService.getLanBypass();
    final bypassStreaming = await _settingsService.getStreamingBypass();
    final isDebug = await _settingsService.getDebugMode();

    // IPv6'yı tamamen kapatıp sadece IPv4 trafiğini tünele yönlendiriyoruz
    String allowedIPs = allowLan ? '0.0.0.0/1, 128.0.0.0/1' : '0.0.0.0/0';

    String excludedAppsConfig = '';
    if (bypassStreaming) {
      excludedAppsConfig = 'ExcludedApplications = com.netflix.mediaclient, com.disney.disneyplus, com.amazon.avod.thirdpartyclient';
    }

    if (isDebug) {
      debugPrint('====================================');
      debugPrint('🛠️ VPN BAĞLANTISI BAŞLATILIYOR 🛠️');
      debugPrint('Sunucu: ${activeServer.city}');
      debugPrint('Kullanılan DNS: $dns');
      debugPrint('MTU: $mtu | Keepalive: $keepalive');
      debugPrint('LAN Erişimi İzni: ${allowLan ? "AÇIK" : "KAPALI"}');
      debugPrint('Yayın Bypass: ${bypassStreaming ? "AKTİF" : "DEVRE DIŞI"}');
      debugPrint('====================================');
    }

    // Seçili olan aktif sunucunun kendi gizli anahtarını dinamik olarak çekiyoruz
    final clientPrivateKey = activeServer.clientPrivateKey;

    return '''
[Interface]
PrivateKey = $clientPrivateKey
Address = ${activeServer.clientAddress}
DNS = $dns
MTU = $mtu
${bypassStreaming ? excludedAppsConfig : ''}

[Peer]
PublicKey = ${activeServer.serverPublicKey}
PresharedKey = ${activeServer.presharedKey}
Endpoint = ${activeServer.ip}:${activeServer.port}
AllowedIPs = $allowedIPs
PersistentKeepalive = $keepalive
''';
  }

  Future<void> _startLiveMetrics() async {
    secondsElapsed = 0;
    totalRxBytes = 0.0;
    totalTxBytes = 0.0;
    actualBlockedAds = 0;
    downSpeed = 0.0;
    upSpeed = 0.0;

    final dns = await _settingsService.getDns();
    // Eğer seçili DNS AdGuard veya Quad9 ise reklam engelleme simülasyonu çalışır
    final hasAdBlockingDns = dns.contains('94.140') || dns.contains('9.9.9.9');

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsElapsed++;

      // 1. Arka Plan Trafiği Simülasyonu (WhatsApp mesajı gelmesi, hava durumu güncellemesi vs.)
      // Saniyede 3 KB - 15 KB arası çok ufak bir dalgalanma
      double rxChunk = 3000.0 + math.Random().nextInt(12000);
      double txChunk = 1500.0 + math.Random().nextInt(4000);

      // 2. Aktif Kullanım Sıçraması (Kullanıcının Instagram'da kaydırması veya site açması)
      // Her 4 ile 8 saniyede bir rastgele gerçekleşir
      if (secondsElapsed % (4 + math.Random().nextInt(5)) == 0) {
        rxChunk +=
            250000.0 +
            math.Random().nextInt(
              900000,
            ); // 250 KB ile 1.1 MB arası ani indirme
        txChunk +=
            40000.0 +
            math.Random().nextInt(80000); // 40 KB - 120 KB arası ani yükleme

        // Kullanıcı yeni bir site açtığında (veri sıçradığında) reklam da engellenmiş olur
        if (hasAdBlockingDns) {
          actualBlockedAds +=
              (1 +
              math.Random().nextInt(3)); // 1 ile 3 adet arası reklam engellendi
        }
      }

      totalRxBytes += rxChunk;
      totalTxBytes += txChunk;

      // Hızları MB/s cinsine çevir
      downSpeed = (rxChunk / 1024 / 1024);
      upSpeed = (txChunk / 1024 / 1024);

      // Ping dalgalanması (+- 1 ms)
      currentPing = activeServer.latencyMs + (secondsElapsed % 3 == 0 ? 1 : 0);

      notifyListeners();
    });
  }

  void _stopLiveMetrics() {
    _sessionTimer?.cancel();
    secondsElapsed = 0;
    downSpeed = 0.0;
    upSpeed = 0.0;
    totalRxBytes = 0.0;
    totalTxBytes = 0.0;
    actualBlockedAds = 0;
    currentPing = activeServer.latencyMs;
    notifyListeners();
  }

  String formatDataSize(double bytes) {
    if (bytes <= 0) return '0.0 MB';
    final mb = bytes / (1024 * 1024);
    if (mb >= 1024) {
      return '${(mb / 1024).toStringAsFixed(2)} GB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }

  String formatTimer(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    final h = (s ~/ 3600);
    final minutes = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$minutes:$sec' : '$m:$sec';
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _vpnSubscription?.cancel();
    super.dispose();
  }
}
