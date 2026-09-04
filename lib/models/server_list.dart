import 'server_location.dart';

class ServerList {
  static final List<ServerLocation> allServers = [
    // 1. GERÇEK ÇALIŞAN SUNUCUN (Almanya) - Bilgileri tam
    ServerLocation(
      id: 'oracle_fra',
      country: 'Almanya',
      city: 'Frankfurt • Oracle OCI',
      flag: '🇩🇪',
      latencyMs: 24,
      ip: '130.61.60.46',
      port: 64492,
      serverPublicKey: 'qhu/0QyYi8boeYNvaRgLdZ2Piz7aJl0tFtzeAsKoRWk=',
      presharedKey: 'RkD9UELHxmC/1eS96co6MTbo/TTJ3pT6t7461GNSUpI=',
      clientAddress: '10.66.66.2/32',
      clientPrivateKey: 'sADIqWrLDEbDpXgmOp0Cp0gjxkyp7BTHlkzkFgg12HM=',
      isMaintenance: false,
    ),

    // 2. AKTİF GÖRÜNEN SUNUCU (Hollanda) - YAYINDAN ÖNCE IP VE KEY GİRİLMELİ
    ServerLocation(
      id: 'nl_ams',
      country: 'Hollanda',
      city: 'Amsterdam • P2P Optimize',
      flag: '🇳🇱',
      latencyMs: 38,
      ip: 'BURAYA_GERCEK_IP_GELECEK',
      port: 51820,
      serverPublicKey: 'BURAYA_PUBLIC_KEY_GELECEK',
      presharedKey: '',
      clientAddress: '10.66.66.3/32',
      clientPrivateKey: '', // Eksik alan eklendi
      isMaintenance: false,
    ),

    // 3. AKTİF GÖRÜNEN SUNUCU (İngiltere) - YAYINDAN ÖNCE IP VE KEY GİRİLMELİ
    ServerLocation(
      id: 'uk_lon',
      country: 'İngiltere',
      city: 'Londra • Premium',
      flag: '🇬🇧',
      latencyMs: 45,
      ip: 'BURAYA_GERCEK_IP_GELECEK',
      port: 51820,
      serverPublicKey: 'BURAYA_PUBLIC_KEY_GELECEK',
      presharedKey: '',
      clientAddress: '10.66.66.4/32',
      clientPrivateKey: '', // Eksik alan eklendi
      isMaintenance: false,
    ),

    // 4. AKTİF GÖRÜNEN SUNUCU (Fransa) - YAYINDAN ÖNCE IP VE KEY GİRİLMELİ
    ServerLocation(
      id: 'fr_par',
      country: 'Fransa',
      city: 'Paris • Standart',
      flag: '🇫🇷',
      latencyMs: 52,
      ip: 'BURAYA_GERCEK_IP_GELECEK',
      port: 51820,
      serverPublicKey: 'BURAYA_PUBLIC_KEY_GELECEK',
      presharedKey: '',
      clientAddress: '10.66.66.5/32',
      clientPrivateKey: '', // Eksik alan eklendi
      isMaintenance: false,
    ),

    // 5. AKTİF GÖRÜNEN SUNUCU (Amerika) - YAYINDAN ÖNCE IP VE KEY GİRİLMELİ
    // 🇺🇸 Google Cloud - Amerika Sunucusu (Free Tier)
    ServerLocation(
      id: 'us_iowa_free',
      country: 'Amerika Birleşik Devletleri',
      city: 'Iowa • Standart Ağ',
      flag: '🇺🇸',
      latencyMs: 145,
      ip: '104.198.53.76',
      port: 51820,
      serverPublicKey: 'IoXtloN9M9uGp7ODKwbKajqagFyRmxlJZjcFOiKB4QU=',
      presharedKey: 'ecgc3qbMskdFz4GjYDDohxoBNHuLhqXHBzEqaZav8Gk=',
      clientAddress: '10.7.0.2/32',
      clientPrivateKey: 'WI4HlDb4GU0H6HjQmgoiGPgbAjcKUTU6EjL82VM/mX8=',
      isMaintenance: false,
    ),

    // --- BURADAN AŞAĞISI BAKIMDA (YAKINDA EKLENECEK) SUNUCULAR ---
    ServerLocation(
      id: 'tr_ist',
      country: 'Türkiye',
      city: 'İstanbul • Yüksek Hız',
      flag: '🇹🇷',
      latencyMs: 12,
      ip: 'mock',
      port: 0,
      serverPublicKey: '',
      presharedKey: '',
      clientAddress: '',
      clientPrivateKey: '', // Eksik alan eklendi
      isMaintenance: true,
    ),
    ServerLocation(
      id: 'ca_tor',
      country: 'Kanada',
      city: 'Toronto • Güvenli',
      flag: '🇨🇦',
      latencyMs: 125,
      ip: 'mock',
      port: 0,
      serverPublicKey: '',
      presharedKey: '',
      clientAddress: '',
      clientPrivateKey: '', // Eksik alan eklendi
      isMaintenance: true,
    ),
    ServerLocation(
      id: 'jp_tok',
      country: 'Japonya',
      city: 'Tokyo • Anime Optimize',
      flag: '🇯🇵',
      latencyMs: 245,
      ip: 'mock',
      port: 0,
      serverPublicKey: '',
      presharedKey: '',
      clientAddress: '',
      clientPrivateKey: '', // Eksik alan eklendi
      isMaintenance: true,
    ),
  ];
}
