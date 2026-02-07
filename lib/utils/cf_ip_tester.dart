import 'dart:io';
import 'dart:async';

class CloudflareIPTester {
  static final List<String> _cfIPs = [
    '104.16.128.1', '104.18.0.1', '172.64.0.1', '188.114.96.1',
    '104.24.0.1', '104.25.0.1', '104.26.0.1', '104.27.0.1',
    '173.245.58.1', '173.245.59.1', '198.41.214.1', '198.41.215.1',
  ];

  static Future<String> findBestIP({int timeoutMs = 2000}) async {
    final results = <(String, int)>[];

    await Future.wait(_cfIPs.map((ip) async {
      final latency = await _testLatency(ip, timeoutMs);
      if (latency != -1) {
        results.add((ip, latency));
      }
    }));

    if (results.isEmpty) return _cfIPs.first;
    
    results.sort((a, b) => a.$2.compareTo(b.$2));
    return results.first.$1;
  }

  static Future<int> _testLatency(String ip, int timeoutMs) async {
    try {
      final socket = await Socket.connect(ip, 443, timeout: Duration(milliseconds: timeoutMs));
      final start = DateTime.now().millisecondsSinceEpoch;
      await socket.add([0x16, 0x03, 0x01]); // TLS handshake start
      await socket.flush();
      socket.destroy();
      return DateTime.now().millisecondsSinceEpoch - start;
    } catch (e) {
      return -1;
    }
  }
}
