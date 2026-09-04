# Aegis WireGuard VPN

Flutter ile geliştirilmiş, WireGuard tünelini mobil uygulama arayüzünden
yönetmeyi amaçlayan bir VPN istemcisi prototipidir. Uygulamanın görünen ürün
adı **Aegis WireGuard VPN**, Flutter paket ve Android application kimliği ise
`wireguard_vpn_app` olarak tanımlıdır.

Bu belge, depodaki mevcut kaynak kodun davranışını açıklar. Uygulama henüz
genel kullanıma hazır, çok sunuculu bir VPN hizmeti değildir: bazı sunucu
kayıtları yer tutucudur, trafik istatistikleri simüle edilir ve WireGuard
özel anahtarları şu anda Dart kaynak kodunda tutulmaktadır. Üretime almadan
önce [Güvenlik ve üretime hazırlık](#güvenlik-ve-üretime-hazırlık) bölümündeki
işler mutlaka tamamlanmalıdır.

## İçindekiler

- [Özellik özeti](#özellik-özeti)
- [Mevcut durum ve önemli uyarılar](#mevcut-durum-ve-önemli-uyarılar)
- [Teknoloji yığını](#teknoloji-yığını)
- [Gereksinimler](#gereksinimler)
- [Kurulum](#kurulum)
- [Çalıştırma ve derleme](#çalıştırma-ve-derleme)
- [Kullanım akışı](#kullanım-akışı)
- [Ayarlar](#ayarlar)
- [WireGuard yapılandırması](#wireguard-yapılandırması)
- [Mimari ve veri akışı](#mimari-ve-veri-akışı)
- [Dizin yapısı](#dizin-yapısı)
- [Sunucu ekleme ve değiştirme](#sunucu-ekleme-ve-değiştirme)
- [Test ve statik analiz](#test-ve-statik-analiz)
- [Platform notları](#platform-notları)
- [Güvenlik ve üretime hazırlık](#güvenlik-ve-üretime-hazırlık)
- [Sorun giderme](#sorun-giderme)
- [Geliştirme yönergeleri](#geliştirme-yönergeleri)
- [Lisans ve sorumluluk](#lisans-ve-sorumluluk)

## Özellik özeti

- Koyu temalı, Material tabanlı VPN ana ekranı.
- WireGuard bağlantısını başlatma ve durdurma.
- Almanya, Amerika Birleşik Devletleri, Hollanda, İngiltere ve Fransa gibi
  konumların listelenmesi.
- Sunucu listesinde ülke/şehir araması.
- Bakımda olan sunucuların bağlantıya kapatılması.
- Seçili sunucunun tahmini gecikmesinin gösterilmesi.
- AdGuard DNS veya filtresiz Cloudflare/Google DNS seçimi.
- LAN erişimi, yayın uygulaması bypass'ı, MTU, Persistent Keepalive ve
  geliştirici logları ayarları.
- Bağlantı süresi, indirme/yükleme hızı, ping, oturum verisi ve engellenen
  reklam sayısı için canlı arayüz göstergeleri.
- `provider` ve `ChangeNotifier` ile ekranlar arası reaktif durum paylaşımı.
- `shared_preferences` ile ayarların cihazda kalıcı saklanması.

## Mevcut durum ve önemli uyarılar

### Çalışan ve prototip olan bölümler

- Kodda tam bağlantı bilgisi bulunan aktif örnek sunucular Almanya
  (`oracle_fra`) ve Amerika Birleşik Devletleri (`us_iowa_free`) kayıtlarıdır.
- Hollanda, İngiltere ve Fransa kayıtlarında gerçek IP ve anahtar yerine
  `BURAYA_GERCEK_IP_GELECEK` ve `BURAYA_PUBLIC_KEY_GELECEK` yer tutucuları
  bulunur; bu kayıtlar bağlantıdan önce tamamlanmalıdır.
- Türkiye, Kanada ve Japonya kayıtları `isMaintenance: true` olduğu için
  kullanıcıya yalnızca bakım iletişim kutusu gösterir.
- Ana ekrandaki trafik, hız ve reklam engelleme sayaçları gerçek WireGuard
  istatistiklerinden okunmaz. `HomeViewModel._startLiveMetrics` içinde zaman
  sayacı ve rastgele veri parçalarıyla simüle edilir.
- Arayüzdeki ping değerleri sunucu kayıtlarındaki sabit `latencyMs` değerleridir;
  gerçek ağ ölçümü yapılmaz.
- Yayın bypass'ı, seçili uygulamaların `ExcludedApplications` satırıyla
  tünel dışında bırakılmasını hedefler. Bunun çalışması platformdaki
  WireGuard eklentisinin bu ayarı desteklemesine bağlıdır.

### Gizli bilgi uyarısı

Depoda `lib/models/server_list.dart` içinde WireGuard istemci özel anahtarı,
önceden paylaşılan anahtar ve sunucu bilgileri; ayrıca `wg0.conf` içinde
sunucu özel anahtarı ve eş bilgileri bulunur. Bu bilgiler gerçekse:

1. Anahtarları derhal döndürün/revoke edin.
2. Gerçek kimlik bilgilerini kaynak kodundan çıkarın.
3. `wg0.conf`, özel anahtarlar ve üretim yapılandırmalarını sürüm kontrolüne
   eklemeyin.
4. Yeni istemci profillerini güvenli bir backend, işletim sistemi anahtar
   deposu veya CI/CD secret yönetimi üzerinden sağlayın.

Bu README hiçbir özel anahtarı tekrar etmez.

## Teknoloji yığını

| Alan | Kullanım |
| --- | --- |
| Flutter/Dart | Uygulama ve kullanıcı arayüzü |
| Dart SDK | `^3.13.1` |
| `wireguard_flutter` | WireGuard native backend entegrasyonu |
| `provider` | `HomeViewModel` ve `SettingsViewModel` enjeksiyonu |
| `shared_preferences` | DNS, MTU, keepalive ve boolean ayarlarının kalıcılığı |
| `google_fonts` | `Plus Jakarta Sans` metin teması |
| `lucide_icons` / Material / Cupertino | Arayüz ikonları ve kontroller |
| Android Gradle Plugin | `9.1.0` |
| Kotlin | `2.4.0` |
| Java | JVM 17 |
| Android compile SDK | 36 |
| Android target SDK | 35 |
| iOS deployment target | 15.0 |
| macOS deployment target | 12.0 |

Ana bağımlılıklar [pubspec.yaml](pubspec.yaml) dosyasında, kilitlenmiş
sürümler [pubspec.lock](pubspec.lock) dosyasındadır.

## Gereksinimler

- Flutter SDK ve Dart SDK (Dart `^3.13.1` ile uyumlu Flutter sürümü).
- `flutter doctor` tarafından doğrulanmış Android toolchain.
- Android için Java 17 ve Android SDK API 36.
- iOS derlemesi için macOS, Xcode ve CocoaPods.
- macOS derlemesi için Xcode ve macOS 12 veya üstü.
- Bağlantıyı gerçekten test etmek için geçerli WireGuard sunucusu, istemci
  özel anahtarı, sunucu public key'i, endpoint ve eşleşen adresler.

Kurulumun doğrulanması:

```bash
flutter doctor -v
```

## Kurulum

1. Proje klasörüne girin:

   ```bash
   cd wireguard_vpn_app
   ```

2. Bağımlılıkları indirin:

   ```bash
   flutter pub get
   ```

3. Bağlı cihazları kontrol edin:

   ```bash
   flutter devices
   ```

4. Platforma özel bağımlılıkları hazırlayın:

   ```bash
   cd ios && pod install && cd ..
   ```

   iOS kullanmayacaksanız bu adım gerekli değildir. `flutter pub get`,
   CocoaPods çalıştırılmadan önce tamamlanmalıdır.

5. Gerçek bağlantı testi yapacaksanız sunucu bilgilerini güvenli bir yöntemle
   sağlayın. Mevcut `ServerList` verisindeki yer tutucularla WireGuard
   bağlantısı kurulamaz.

## Çalıştırma ve derleme

### Geliştirme çalıştırması

```bash
flutter run
```

Belirli bir cihaz/platform için:

```bash
flutter run -d <device-id>
```

### Android

```bash
flutter build apk --debug
flutter build apk --release
```

Android manifest'i internet, ağ durumu ve foreground service izinlerini tanımlar
ve WireGuard backend VPN servisini `BIND_VPN_SERVICE` ile kaydeder.

### iOS

```bash
flutter build ios --debug
flutter build ios --release
```

iOS Podfile minimum iOS sürümünü 15.0 olarak ayarlar. App Store/TestFlight
dağıtımı için debug imzalama yapılandırmasını release imzalama ile değiştirin.

### macOS

```bash
flutter build macos
```

macOS Podfile minimum macOS sürümünü 12.0 olarak ayarlar.

### Web, Windows ve Linux

Proje Flutter'ın bu platformlara ait kabuk dosyalarını içerir; ancak
WireGuard eklentisinin gerçek VPN backend davranışı platforma göre değişir.
Web tarayıcıları işletim sistemi seviyesinde VPN tüneli açamaz. Windows ve
Linux için de bu depoda tamamlanmış bir native WireGuard servis yapılandırması
bulunmadığından bu hedefler şu an üretim VPN istemcisi olarak kabul edilmemelidir.

## Kullanım akışı

1. Uygulama açıldığında `ApexHomePage` gösterilir.
2. `HomeViewModel` varsayılan olarak `ServerList.allServers.first`, yani
   Almanya/Frankfurt kaydını seçer ve WireGuard arayüzünü `wg0` adıyla
   başlatmayı dener.
3. Sunucu kartına dokunarak `ServerSelectionPage` açılır.
4. Ülke veya şehir aratılır; aktif sunucu neon çerçeveyle belirtilir.
5. Bakımda olmayan bir sunucu seçilirse seçim `HomeViewModel` içine yazılır ve
   ana ekrana dönülür.
6. Ana ekrandaki güç düğmesine dokunulunca ayarlar okunur, dinamik
   `wg-quick` benzeri yapılandırma oluşturulur ve `wireguard_flutter` ile
   başlatılır.
7. Native eklenti `connected` bildirirse sayaçlar başlar; `disconnected`
   bildirirse sayaçlar sıfırlanır.
8. Ayarlar ikonundan `SettingsPage` açılır; değişiklikler anında kaydedilir.

Bağlantı kurulurken tekrar tekrar güç düğmesine basılması `isConnecting`
koruması nedeniyle yok sayılır. Native servis hata verirse durum sıfırlanır ve
ana ekranda `SnackBar` ile hata gösterilir.

## Ayarlar

### DNS

- **AdGuard DNS:** `94.140.14.14, 94.140.15.15`; arayüzde filtreleme aktif
  olarak sunulur.
- **Cloudflare & Google:** `1.1.1.1, 8.8.8.8`; filtresiz ve düşük gecikmeli
  seçenek olarak sunulur.

DNS değeri `selected_dns_ip` anahtarıyla saklanır ve varsayılanı AdGuard'dır.

### Yerel ağ erişimi

Kapalıyken `AllowedIPs = 0.0.0.0/0`, açıkken iki IPv4 yarısı olan
`0.0.0.0/1, 128.0.0.0/1` kullanılır. Bu alanın adı arayüzde LAN bypass
olarak geçse de gerçek yönlendirme davranışı platform backend'ine ve işletim
sistemi routing kurallarına bağlıdır.

### Yayın optimizasyonu

Aktifken şu uygulamalar için `ExcludedApplications` satırı oluşturulur:

- `com.netflix.mediaclient`
- `com.disney.disneyplus`
- `com.amazon.avod.thirdpartyclient`

### MTU

Slider 1280 ile 1480 arasında 20 bölmeli çalışır; varsayılan 1420 byte'tır.
Değer `mtu_size` anahtarıyla kaydedilir.

### Persistent Keepalive

Seçenekler `Kapalı` (0), 15 saniye ve 25 saniyedir. Varsayılan 25 saniyedir
ve `keepalive_interval` anahtarında tutulur.

### Geliştirici logları

`debug_mode` açıkken bağlantı kurulmadan önce sunucu, DNS, MTU, keepalive,
LAN ve yayın bypass durumları debug konsoluna yazılır. Üretimde özel bilgi
sızıntısı ihtimali nedeniyle kapalı tutulmalıdır.

## WireGuard yapılandırması

`VpnService` şu çağrıları yapar:

```dart
await _wireguard.initialize(interfaceName: 'wg0');
await _wireguard.startVpn(
  serverAddress: '$ip:$port',
  wgQuickConfig: config,
  providerBundleIdentifier: 'com.example.wireguard_vpn_app',
);
```

`HomeViewModel._buildQuickConfig()` tarafından oluşturulan yapılandırmanın
şeması şöyledir:

```ini
[Interface]
PrivateKey = <istemci özel anahtarı>
Address = <istemci adresi>
DNS = <seçili DNS>
MTU = <MTU>

[Peer]
PublicKey = <sunucu public key>
PresharedKey = <PSK>
Endpoint = <sunucu IP>:<UDP portu>
AllowedIPs = <yönlendirme aralığı>
PersistentKeepalive = <saniye>
```

Gerçek anahtarları README'ye, issue'lara, ekran görüntülerine veya loglara
eklemeyin. Depodaki `wg0.conf` ise istemci uygulamasının ürettiği config değil,
sunucu tarafı için örnek bir WireGuard yapılandırmasıdır; içinde firewall,
NAT, forwarding ve bir istemci peer tanımı bulunur.

## Mimari ve veri akışı

Uygulama basit bir MVVM düzeni kullanır:

```text
UI (Views/Widgets)
        │ Provider / ChangeNotifier
        ▼
ViewModels
   ┌────┴─────┐
   ▼          ▼
VpnService  SettingsService
   │          │
   ▼          ▼
WireGuard   SharedPreferences
native API
```

### Başlangıç

- `main()` Flutter binding'i hazırlar.
- `HomeViewModel` ve `SettingsViewModel` `MultiProvider` ile uygulama ağacına
  eklenir.
- `ApexVpnApp` koyu tema, `Plus Jakarta Sans` ve `ApexHomePage` ana rotasını
  tanımlar.

### `HomeViewModel`

- Aktif sunucu, bağlantı/bağlanma durumu ve ekran metriklerini taşır.
- WireGuard stage stream'ini dinler.
- Bağlantı yaşam döngüsünü ve periyodik metrik simülasyonunu yönetir.
- `dispose()` içinde timer ve stream subscription nesnelerini kapatır.

### `SettingsViewModel` ve `SettingsService`

`SettingsViewModel` UI olaylarını alır, haptic feedback üretir, yerel alanları
günceller ve `SettingsService` üzerinden kalıcı depolamaya yazar.
`SettingsService`, `SharedPreferences` örneğini lazy biçimde bir kez yükleyip
önbellekte tutar.

### Görünümler

- `home_page.dart`: durum rozeti, sunucu kartı, güç düğmesi, süre, grafik ve
  metrik kartları.
- `server_selection_page.dart`: arama, ping rengi, aktif sunucu ve bakım
  iletişim kutusu.
- `settings_page.dart`: DNS kartları, bypass anahtarları, MTU slider'ı,
  keepalive dropdown'ı ve debug switch'i.
- `custom_vpn_widgets.dart`: canlı rozetler, metrik öğeleri ve sinüs dalgası
  `CustomPainter`.

## Dizin yapısı

```text
.
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── server_list.dart
│   │   └── server_location.dart
│   ├── services/
│   │   ├── settings_service.dart
│   │   └── vpn_service.dart
│   ├── viewmodels/
│   │   ├── home_viewmodel.dart
│   │   └── settings_viewmodel.dart
│   └── views/
│       ├── home_page.dart
│       ├── server_selection_page.dart
│       ├── settings_page.dart
│       └── widgets/custom_vpn_widgets.dart
├── test/app_test.dart
├── android/
├── ios/
├── macos/
├── linux/
├── windows/
├── web/
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
└── wg0.conf
```

`build/`, `.dart_tool/`, CocoaPods ve platform derleme çıktıları kaynak
dosyası değildir; `.gitignore` tarafından dışlanır ve README kapsamındaki
uygulama mantığının parçası olarak düzenlenmemelidir.

## Sunucu ekleme ve değiştirme

Yeni bir kayıt eklemek için `ServerLocation` alanlarının tamamını doldurun:

- benzersiz `id`
- ülke, şehir ve bayrak
- kullanıcıya gösterilecek `latencyMs`
- gerçek endpoint IP'si ve UDP portu
- sunucu public key'i
- gerekiyorsa preshared key
- istemci adresi (`10.x.x.x/32` gibi)
- istemci özel anahtarı
- geçici kayıtlar için `isMaintenance: true`

Yeni sunucu ekledikten sonra:

1. Yer tutucu, boş anahtar ve port değerlerini kontrol edin.
2. Sunucu tarafındaki peer public key ve adres eşleşmesini doğrulayın.
3. Uygulama dışında anahtarların rotate edilip edilmediğini kontrol edin.
4. Bağlantı, kopma, yeniden bağlanma ve yanlış credential senaryolarını test
   edin.
5. Gerçek ping ve trafik ölçümü eklenmedikçe `latencyMs` değerini tahmini
   değer olarak belgeleyin.

VPN bağlıyken sunucu değiştirme davranışı ayrıca ele alınmalıdır; mevcut kod
seçimi günceller fakat mevcut tüneli otomatik olarak durdurup yeni sunucuya
geçiş yapmaz.

## Test ve statik analiz

Projede `test/app_test.dart` içinde şunlar için testler bulunur:

- `SettingsService` varsayılanları ve false/0 değerlerinin saklanması.
- Tüm tercihlerden WireGuard config üretilmesi.
- Bağlanma sırasında tekrarlı toggle'ın engellenmesi.
- Veri boyutu ve süre formatlama sınırları.
- Servis hatasında durumun sıfırlanması ve hata SnackBar'ı.
- Ana ekrandan ayarlara navigasyon.
- Ayarlar ekranında switch, DNS, slider ve keepalive güncellemeleri.

Çalıştırılacak komutlar:

```bash
flutter analyze
flutter test
```

Mevcut kaynak durumunda `flutter analyze`, testlerde
`HomeViewModel.toggleVPN` metoduna fazladan `BuildContext` argümanı
verilmesinden dolayı üç hata raporlar. Ayrıca bir test IPv6 içeren eski bir
`AllowedIPs` çıktısı beklerken mevcut üretim kodu yalnızca IPv4 aralıkları
oluşturur. Bu nedenle test/uygulama sözleşmesi düzeltilmeden temiz bir CI
sonucu varsayılmamalıdır.

## Platform notları

- Android `INTERNET`, `ACCESS_NETWORK_STATE`, `FOREGROUND_SERVICE` ve
  `FOREGROUND_SERVICE_CONNECTED_DEVICE` izinlerini tanımlar.
- Android `MainActivity`, standart `FlutterActivity` sınıfıdır; native özel
  iş mantığı eklenti tarafından sağlanır.
- iOS için `AppDelegate` implicit Flutter engine içindeki plugin'leri
  kaydeder; deployment target 15.0'dır.
- macOS için standart Flutter app delegate kullanılır; deployment target
  12.0'dır.
- Windows/Linux/web kabukları mevcut olsa da WireGuard VPN özelliğinin bu
  hedeflerde çalıştığı kabul edilmemelidir.
- Generated plugin registrant dosyaları Flutter tarafından üretilir; elle
  düzenlenmemelidir.

## Güvenlik ve üretime hazırlık

Üretim öncesi minimum kontrol listesi:

- [ ] Tüm gerçek private key, PSK ve sunucu sırları kaynak kodundan çıkarıldı.
- [ ] Depoya daha önce girmiş anahtarlar rotate edildi.
- [ ] Sunucu listesi güvenli bir API/config dağıtım mekanizmasına taşındı.
- [ ] TLS, sertifika doğrulama, kimlik doğrulama ve yetkilendirme tasarlandı.
- [ ] Kullanıcıya özel WireGuard profilleri cihazın güvenli key store'unda
      saklanıyor.
- [ ] Debug loglarında IP, anahtar ve hassas bağlantı bilgisi sızmıyor.
- [ ] Gerçek trafik sayaçları native WireGuard istatistiklerinden okunuyor.
- [ ] Gerçek ping ölçümü ve bağlantı timeout/retry politikası eklendi.
- [ ] IPv4/IPv6 routing, DNS leak, kill switch ve LAN bypass politikaları
      güvenlik incelemesinden geçirildi.
- [ ] Android VPN izin akışı ve iOS/macOS Network Extension yetkileri
      gerçek cihazlarda doğrulandı.
- [ ] Release imzalama, obfuscation, store metadata ve gizlilik politikası
      hazırlandı.
- [ ] Sunucu seçimi bağlantı sırasında kontrollü yeniden bağlantı davranışına
      sahip.
- [ ] Testlerdeki güncel API ve `AllowedIPs` sözleşmesiyle uyumsuzluklar
      giderildi.

## Sorun giderme

### `flutter pub get` veya CocoaPods başarısız

Flutter sürümünü `flutter doctor -v` ile kontrol edin. Ardından:

```bash
flutter clean
flutter pub get
cd ios && pod install --repo-update && cd ..
```

### VPN başlatılamıyor

- Cihazın VPN izni verdiğini doğrulayın.
- Endpoint IP/port ve UDP firewall kuralını kontrol edin.
- İstemci `PrivateKey`, sunucu `PublicKey`, PSK ve adres eşleşmesini kontrol
  edin.
- Seçili sunucunun bakımda veya yer tutucu değerli olmadığını doğrulayın.
- Debug Mode'u yalnızca geliştirme cihazında açıp native hata çıktısını
  inceleyin.

### Bağlantı var ama trafik yok

- Sunucuda IP forwarding ve NAT kurallarını kontrol edin.
- `AllowedIPs`, MTU ve DNS değerlerini deneyin.
- WireGuard sunucu peer'inin istemci adresiyle eşleştiğini kontrol edin.
- IPv6 trafiğinin mevcut yapılandırmada kapsanmadığını unutmayın.

### Metrikler gerçekçi görünmüyor

Bu beklenen prototip davranışıdır. Hız, toplam veri ve reklam sayaçları
`HomeViewModel` içinde simüle edilir; gerçek üretim metriği değildir.

## Geliştirme yönergeleri

- UI mantığını view'lara yığmak yerine view model/service katmanlarını kullanın.
- Yeni ayar eklerken `SettingsService`, `SettingsViewModel`, UI ve testleri
  birlikte güncelleyin.
- Yeni sunucu eklerken gerçek sırları kod incelemesine sokmayın.
- Generated platform dosyalarını elle değiştirmeyin.
- Değişiklikten sonra en azından `flutter analyze` ve ilgili
  `flutter test --name ...` testlerini çalıştırın.
- Yönlendirme veya güvenlik davranışı değişiyorsa gerçek cihaz ve gerçek
  WireGuard sunucusuyla ayrıca doğrulama yapın.

## Lisans ve sorumluluk

Bu depo için ayrı bir lisans dosyası bulunmamaktadır; yeniden dağıtım veya
ticari kullanım koşullarını proje sahibi belirlemelidir. WireGuard,
WireGuard ekosisteminin ilgili lisans ve marka koşullarına tabidir.
Uygulamanın güvenlik, anonimlik veya kesintisiz erişim sağladığı garanti
edilmez; gerçek dağıtım öncesi yetkili bir güvenlik ve ağ incelemesi yapılmalıdır.
