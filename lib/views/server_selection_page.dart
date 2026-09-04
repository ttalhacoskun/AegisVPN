import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/server_list.dart';
import '../models/server_location.dart';
import '../viewmodels/home_viewmodel.dart';

class ServerSelectionPage extends StatefulWidget {
  const ServerSelectionPage({super.key});

  @override
  State<ServerSelectionPage> createState() => _ServerSelectionPageState();
}

class _ServerSelectionPageState extends State<ServerSelectionPage> {
  String _searchQuery = '';

  List<ServerLocation> get _filteredServers {
    if (_searchQuery.isEmpty) return ServerList.allServers;
    return ServerList.allServers.where((server) {
      return server.country.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          server.city.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _onServerTap(ServerLocation server) {
    if (server.isMaintenance) {
      HapticFeedback.heavyImpact();
      _showMaintenanceDialog(server.country);
      return;
    }

    HapticFeedback.lightImpact();
    // VPN bağlıysa uyarı verilebilir veya doğrudan değiştirilebilir.
    // Şimdilik sadece sunucuyu güncelliyoruz.
    context.read<HomeViewModel>().changeServer(server);
    Navigator.pop(context);
  }

  void _showMaintenanceDialog(String country) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Sunucu Bakımda'),
        content: Text(
          '$country sunucusu şu anda altyapı güçlendirme çalışmasında veya yakında eklenecek. Lütfen aktif olan Almanya sunucusunu kullanın.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Anladım'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  Color _getPingColor(int ping) {
    if (ping < 80) return const Color(0xFF00FFA3); // Neon Yeşil
    if (ping < 150) return Colors.amberAccent; // Sarı
    return Colors.redAccent; // Kırmızı
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF070B14);
    const cardColor = Color(0xFF101728);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Konum Seç',
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
      body: Column(
        children: [
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Ülke veya şehir ara...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                filled: true,
                fillColor: cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Sunucu Listesi
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredServers.length,
              itemBuilder: (context, index) {
                final server = _filteredServers[index];
                final isActive =
                    context.watch<HomeViewModel>().activeServer.id == server.id;
                final pingColor = _getPingColor(server.latencyMs);

                return GestureDetector(
                  onTap: () => _onServerTap(server),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF00FFA3).withValues(alpha: 0.05)
                          : cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFF00FFA3).withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.05),
                        width: isActive ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(server.flag, style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                server.country,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: server.isMaintenance
                                      ? Colors.white54
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                server.city,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Sağ Taraf (Ping veya Kilit/Bakım İkonu)
                        if (server.isMaintenance)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.build_circle_rounded,
                                  size: 14,
                                  color: Colors.white54,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'BAKIMDA',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Row(
                            children: [
                              Text(
                                '${server.latencyMs} ms',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: pingColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.signal_cellular_alt_rounded,
                                size: 16,
                                color: pingColor,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
