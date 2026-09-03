class ServerLocation {
  final String id;
  final String country;
  final String city;
  final String flag;
  final int latencyMs;
  final String ip;
  final int port;
  final String serverPublicKey;
  final String presharedKey;
  final String clientAddress;

  const ServerLocation({
    required this.id,
    required this.country,
    required this.city,
    required this.flag,
    required this.latencyMs,
    required this.ip,
    required this.port,
    required this.serverPublicKey,
    required this.presharedKey,
    required this.clientAddress,
  });
}
