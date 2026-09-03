import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/settings_viewmodel.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  final List<Map<String, String>> _dnsOptions = const [
    {
      'title': 'AdGuard DNS',
      'subtitle': 'Filtreleme Aktif',
      'ip': '94.140.14.14, 94.140.15.15',
      'desc': 'Reklam, takipçi ve zararlı içerikleri engeller.',
      'icon': 'shield_rounded',
    },
    {
      'title': 'Cloudflare & Google',
      'subtitle': 'Filtresiz & Maksimum Hız',
      'ip': '1.1.1.1, 8.8.8.8',
      'desc': 'Tüm istekleri doğrudan yönlendirir, minimum gecikme.',
      'icon': 'bolt_rounded',
    },
  ];

  IconData _getIcon(String iconName) {
    if (iconName == 'shield_rounded') return Icons.shield_rounded;
    if (iconName == 'bolt_rounded') return Icons.bolt_rounded;
    return Icons.dns_rounded;
  }

  @override
  Widget build(BuildContext context) {
    const neon = Color(0xFF00FFA3);
    const bgColor = Color(0xFF070B14);
    const cardColor = Color(0xFF101728);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Tünel Yapılandırması',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, vm, child) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _buildSectionHeader('GÜNLÜK KULLANIM & MEDYA'),
              const SizedBox(height: 12),
              _buildSwitchTile(
                title: 'Yerel Ağ (LAN) Erişimi',
                desc: 'VPN açıkken evdeki Akıllı TV, yazıcı veya diğer cihazlara erişime izin ver.',
                icon: Icons.cast_connected_rounded,
                iconColor: Colors.purpleAccent,
                value: vm.allowLan,
                onChanged: vm.toggleLanBypass,
                cardColor: cardColor,
                activeColor: neon,
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                title: 'Yayın Optimizasyonu',
                desc: 'Film/Dizi platformlarındaki (Netflix, Disney+ vb.) bağlantı ve bölge kısıtlamalarını aşmak için onları tünel dışında bırak.',
                icon: Icons.movie_filter_rounded,
                iconColor: Colors.orangeAccent,
                value: vm.bypassStreaming,
                onChanged: vm.toggleStreamingBypass,
                cardColor: cardColor,
                activeColor: neon,
              ),

              const SizedBox(height: 32),
              _buildSectionHeader('GÜVENLİK VE DNS ÇÖZÜMLEME'),
              const SizedBox(height: 12),
              ..._dnsOptions.map((opt) {
                final isSelected = vm.selectedDnsIp == opt['ip'];
                return _buildDnsCard(
                  title: opt['title']!,
                  subtitle: opt['subtitle']!,
                  desc: opt['desc']!,
                  icon: _getIcon(opt['icon']!),
                  isSelected: isSelected,
                  neonColor: neon,
                  cardColor: cardColor,
                  onTap: () => vm.setDns(opt['ip']!),
                );
              }),

              const SizedBox(height: 32),
              _buildSectionHeader('ÇEKİRDEK & GELİŞTİRİCİ AYARLARI'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.speed_rounded, color: neon, size: 20),
                            const SizedBox(width: 12),
                            const Text(
                              'MTU Büyüklüğü',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${vm.mtuSize} Bytes',
                          style: const TextStyle(
                            color: neon,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: neon,
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                        thumbColor: Colors.white,
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: vm.mtuSize.toDouble(),
                        min: 1280,
                        max: 1480,
                        divisions: 20,
                        onChangeEnd: (_) => vm.setMtuFinished(),
                        onChanged: (v) => vm.setMtu(v.toInt()),
                      ),
                    ),
                    const Divider(height: 32, color: Colors.white10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Persistent Keepalive',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: vm.keepaliveSecs,
                            dropdownColor: cardColor,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                            items: const [
                              DropdownMenuItem(value: 0, child: Text('Kapalı')),
                              DropdownMenuItem(value: 15, child: Text('15 sn')),
                              DropdownMenuItem(value: 25, child: Text('25 sn')),
                            ],
                            onChanged: (val) {
                              if (val != null) vm.setKeepalive(val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32, color: Colors.white10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Geliştirici Logları',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bağlantı teşhisi ve konsol çıktıları için hata ayıklama modunu aktifleştirir.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        CupertinoSwitch(
                          value: vm.debugMode,
                          activeTrackColor: neon,
                          onChanged: vm.toggleDebugMode,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: Colors.white54,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String desc,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color cardColor,
    required Color activeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value
              ? activeColor.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CupertinoSwitch(
            value: value,
            activeTrackColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDnsCard({
    required String title,
    required String subtitle,
    required String desc,
    required IconData icon,
    required bool isSelected,
    required Color neonColor,
    required Color cardColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? neonColor.withValues(alpha: 0.03) : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? neonColor.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.05),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? neonColor.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? neonColor : Colors.white70,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: neonColor,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? neonColor.withValues(alpha: 0.9)
                          : Colors.blueAccent.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
