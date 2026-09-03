import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/home_viewmodel.dart';
import 'settings_page.dart';
import 'widgets/custom_vpn_widgets.dart';

class ApexHomePage extends StatefulWidget {
  const ApexHomePage({super.key});

  @override
  State<ApexHomePage> createState() => _ApexHomePageState();
}

class _ApexHomePageState extends State<ApexHomePage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const neon = Color(0xFF00FFA3);
    const cyan = Color(0xFF00B2FF);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Consumer<HomeViewModel>(
            builder: (context, vm, child) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF101728),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: vm.isConnected
                                    ? neon
                                    : Colors.orangeAccent,
                                boxShadow: vm.isConnected
                                    ? [
                                        const BoxShadow(
                                          color: neon,
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              vm.isConnected
                                  ? 'ŞİFRELİ TÜNEL AKTİF'
                                  : 'BAĞLANTI YOK',
                              style: const TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.tune_rounded,
                          size: 22,
                          color: Colors.white70,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101728),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Text(
                          vm.activeServer.flag,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vm.activeServer.country,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${vm.activeServer.city} • UDP ${vm.activeServer.port}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.verified_user_rounded,
                          color: neon,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      RotationTransition(
                        turns: _rotationController,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: (vm.isConnected ? neon : cyan).withValues(
                                alpha: 0.18,
                              ),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: vm.isConnecting
                            ? null
                            : () => vm.toggleVPN(context),
                        child: Container(
                          width: 155,
                          height: 155,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0C1322),
                            border: Border.all(
                              color: vm.isConnected
                                  ? neon
                                  : cyan.withValues(alpha: 0.6),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (vm.isConnected ? neon : cyan)
                                    .withValues(
                                      alpha: vm.isConnected ? 0.35 : 0.15,
                                    ),
                                blurRadius: 36,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: vm.isConnecting
                                ? const SizedBox(
                                    width: 38,
                                    height: 38,
                                    child: CircularProgressIndicator(
                                      color: neon,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : Icon(
                                    Icons.power_settings_new_rounded,
                                    size: 62,
                                    color: vm.isConnected
                                        ? neon
                                        : Colors.white54,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    vm.isConnected
                        ? vm.formatTimer(vm.secondsElapsed)
                        : '00:00',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: vm.isConnected ? Colors.white : Colors.white24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vm.isConnecting
                        ? 'YAPILANDIRILIYOR...'
                        : (vm.isConnected
                              ? 'KORUMA ALTINDASINIZ'
                              : 'BAĞLANMAK İÇİN DOKUNUN'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: vm.isConnected ? neon : Colors.white38,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1424),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        LiveShieldBadge(
                          label: 'FİLTRELENEN',
                          val: vm.isConnected
                              ? '${vm.actualBlockedAds} Adet'
                              : '0 Adet',
                          icon: Icons.shield_rounded,
                          color: neon,
                        ),
                        Container(height: 24, width: 1, color: Colors.white10),
                        LiveShieldBadge(
                          label: 'OTURUM VERİSİ',
                          val: vm.isConnected
                              ? vm.formatDataSize(
                                  vm.totalRxBytes + vm.totalTxBytes,
                                )
                              : '0.0 MB',
                          icon: Icons.data_usage_rounded,
                          color: cyan,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 28,
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, _) => CustomPaint(
                        painter: HarmonicSmoothWavePainter(
                          progress: _waveController.value,
                          isActive: vm.isConnected,
                          waveColor: vm.isConnected
                              ? neon
                              : cyan.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101728),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        LiveMetricItem(
                          label: 'İNDİRME',
                          val: '${vm.downSpeed.toStringAsFixed(1)} MB/s',
                          icon: Icons.arrow_downward_rounded,
                          color: neon,
                        ),
                        Container(height: 24, width: 1, color: Colors.white10),
                        LiveMetricItem(
                          label: 'YÜKLEME',
                          val: '${vm.upSpeed.toStringAsFixed(1)} MB/s',
                          icon: Icons.arrow_upward_rounded,
                          color: cyan,
                        ),
                        Container(height: 24, width: 1, color: Colors.white10),
                        LiveMetricItem(
                          label: 'GECİKME',
                          val: '${vm.currentPing} ms',
                          icon: Icons.bolt_rounded,
                          color: Colors.amberAccent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
