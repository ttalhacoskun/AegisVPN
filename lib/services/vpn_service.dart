import 'package:wireguard_flutter/wireguard_flutter.dart';

class VpnService {
  final _wireguard = WireGuardFlutter.instance;

  Future<void> initialize() async {
    await _wireguard.initialize(interfaceName: 'wg0');
  }

  Stream<VpnStage> get vpnStageStream => _wireguard.vpnStageSnapshot;

  Future<void> startVpn(String serverAddress, String config) async {
    await _wireguard.startVpn(
      serverAddress: serverAddress,
      wgQuickConfig: config,
      providerBundleIdentifier: 'com.example.wireguard_vpn_app',
    );
  }

  Future<void> stopVpn() async {
    await _wireguard.stopVpn();
  }
}
