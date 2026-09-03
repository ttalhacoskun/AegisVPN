import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';
import 'package:wireguard_vpn_app/main.dart';
import 'package:wireguard_vpn_app/services/settings_service.dart';
import 'package:wireguard_vpn_app/services/vpn_service.dart';
import 'package:wireguard_vpn_app/viewmodels/home_viewmodel.dart';
import 'package:wireguard_vpn_app/viewmodels/settings_viewmodel.dart';
import 'package:wireguard_vpn_app/views/settings_page.dart';

class FakeVpnService extends VpnService {
  final stages = StreamController<VpnStage>.broadcast();
  String? startedAddress;
  String? startedConfig;
  int startCalls = 0;
  int stopCalls = 0;
  Object? startError;

  @override
  Future<void> initialize() async {}

  @override
  Stream<VpnStage> get vpnStageStream => stages.stream;

  @override
  Future<void> startVpn(String serverAddress, String config) async {
    startCalls++;
    startedAddress = serverAddress;
    startedConfig = config;
    if (startError != null) throw startError!;
    stages.add(VpnStage.connected);
  }

  @override
  Future<void> stopVpn() async {
    stopCalls++;
    stages.add(VpnStage.disconnected);
  }

  Future<void> close() => stages.close();
}

class FakeSettingsService extends SettingsService {
  String dns = '94.140.14.14, 94.140.15.15';
  int mtu = 1420;
  int keepalive = 25;
  bool lan = false;
  bool streaming = false;
  bool debug = false;

  @override
  Future<String> getDns() async => dns;
  @override
  Future<void> setDns(String value) async => dns = value;
  @override
  Future<int> getMtu() async => mtu;
  @override
  Future<void> setMtu(int value) async => mtu = value;
  @override
  Future<int> getKeepalive() async => keepalive;
  @override
  Future<void> setKeepalive(int value) async => keepalive = value;
  @override
  Future<bool> getLanBypass() async => lan;
  @override
  Future<void> setLanBypass(bool value) async => lan = value;
  @override
  Future<bool> getStreamingBypass() async => streaming;
  @override
  Future<void> setStreamingBypass(bool value) async => streaming = value;
  @override
  Future<bool> getDebugMode() async => debug;
  @override
  Future<void> setDebugMode(bool value) async => debug = value;
}

Widget testApp(HomeViewModel home, SettingsViewModel settings) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: home),
      ChangeNotifierProvider.value(value: settings),
    ],
    child: const ApexVpnApp(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('returns documented defaults', () async {
      final service = SettingsService();
      expect(await service.getDns(), '94.140.14.14, 94.140.15.15');
      expect(await service.getMtu(), 1420);
      expect(await service.getKeepalive(), 25);
      expect(await service.getLanBypass(), isFalse);
      expect(await service.getStreamingBypass(), isFalse);
      expect(await service.getDebugMode(), isFalse);
    });

    test('persists every setting and supports false/zero values', () async {
      final service = SettingsService();
      await service.setDns('1.1.1.1, 8.8.8.8');
      await service.setMtu(1280);
      await service.setKeepalive(0);
      await service.setLanBypass(true);
      await service.setStreamingBypass(true);
      await service.setDebugMode(true);

      expect(await service.getDns(), '1.1.1.1, 8.8.8.8');
      expect(await service.getMtu(), 1280);
      expect(await service.getKeepalive(), 0);
      expect(await service.getLanBypass(), isTrue);
      expect(await service.getStreamingBypass(), isTrue);
      expect(await service.getDebugMode(), isTrue);
    });
  });

  group('HomeViewModel', () {
    late FakeVpnService vpn;
    late FakeSettingsService settings;
    late HomeViewModel model;

    setUp(() async {
      vpn = FakeVpnService();
      settings = FakeSettingsService();
      model = HomeViewModel(vpnService: vpn, settingsService: settings);
      await Future<void>.delayed(Duration.zero);
    });

    tearDown(() async {
      model.dispose();
      await vpn.close();
    });

    test('builds a full config from all preferences', () async {
      settings.dns = '1.1.1.1, 8.8.8.8';
      settings.mtu = 1280;
      settings.keepalive = 0;
      settings.lan = true;
      settings.streaming = true;

      await model.toggleVPN(MockBuildContext());

      expect(vpn.startedAddress, '130.61.60.46:64492');
      expect(vpn.startedConfig, contains('DNS = 1.1.1.1, 8.8.8.8'));
      expect(vpn.startedConfig, contains('MTU = 1280'));
      expect(
        vpn.startedConfig,
        contains('AllowedIPs = 0.0.0.0/1, 128.0.0.0/1, ::/1, 8000::/1'),
      );
      expect(vpn.startedConfig, contains('PersistentKeepalive = 0'));
      expect(vpn.startedConfig, contains('ExcludedApplications ='));
      expect(model.isConnected, isTrue);
      expect(model.isConnecting, isFalse);
    });

    test('ignores repeated toggles while connecting', () async {
      model.isConnecting = true;
      await model.toggleVPN(MockBuildContext());
      expect(vpn.startCalls, 0);
    });

    test('formats bytes and elapsed time at boundaries', () {
      expect(model.formatDataSize(0), '0.0 MB');
      expect(model.formatDataSize(1024 * 1024), '1.0 MB');
      expect(model.formatDataSize(1024 * 1024 * 1024), '1.00 GB');
      expect(model.formatTimer(0), '00:00');
      expect(model.formatTimer(65), '01:05');
      expect(model.formatTimer(3661), '01:01:01');
    });
  });

  testWidgets('reports service errors and resets state', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vpn = FakeVpnService()..startError = StateError('offline');
    final home = HomeViewModel(
      vpnService: vpn,
      settingsService: FakeSettingsService(),
    );
    final settings = SettingsViewModel(settingsService: FakeSettingsService());
    addTearDown(() async {
      home.dispose();
      settings.dispose();
      await vpn.close();
    });

    await tester.pumpWidget(testApp(home, settings));
    final context = tester.element(find.byType(Scaffold).first);

    await home.toggleVPN(context);
    await tester.pump();

    expect(home.isConnected, isFalse);
    expect(home.isConnecting, isFalse);
    expect(find.text('Bağlantı Hatası: Bad state: offline'), findsOneWidget);
  });

  testWidgets('home screen navigates to settings and renders initial state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vpn = FakeVpnService();
    final home = HomeViewModel(
      vpnService: vpn,
      settingsService: FakeSettingsService(),
    );
    final settings = SettingsViewModel(settingsService: FakeSettingsService());
    addTearDown(() async {
      home.dispose();
      settings.dispose();
      await vpn.close();
    });

    await tester.pumpWidget(testApp(home, settings));
    expect(find.text('BAĞLANTI YOK'), findsOneWidget);
    expect(find.text('BAĞLANMAK İÇİN DOKUNUN'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.text('Tünel Yapılandırması'), findsOneWidget);
  });

  testWidgets('settings screen updates switches, DNS, slider and keepalive', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fake = FakeSettingsService();
    final model = SettingsViewModel(settingsService: fake);
    addTearDown(model.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: model,
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(CupertinoSwitch).first);
    await tester.tap(find.text('Cloudflare & Google'));
    await tester.tap(find.text('25 sn'));
    await tester.pump();
    await tester.tap(find.text('Kapalı').last);
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.drag(
      find.byType(Slider, skipOffstage: false),
      const Offset(60, 0),
    );
    await tester.pumpAndSettle();

    expect(fake.lan, isTrue);
    expect(fake.dns, '1.1.1.1, 8.8.8.8');
    expect(fake.mtu, isNot(1420));
    expect(fake.mtu, inInclusiveRange(1280, 1480));
    expect(fake.keepalive, 0);
  });
}

class MockBuildContext implements BuildContext {
  @override
  bool get mounted => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
