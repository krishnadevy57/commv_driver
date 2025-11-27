import 'dart:async';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'storage_service.dart';

class SocketService extends GetxService {
  late IO.Socket socket;
  RxList<String> logs = <String>[].obs;
  String? token;
  bool _connected = false;

  Future<SocketService> init({bool backgroundMode = false}) async {
    // Load token (works whether background or foreground)
    token = await StorageService.instance.token;
    log('Token loaded: ${token != null ? "[present]" : "[null]"}');

    _initSocket();
    return this;
  }

  void _initSocket() {
    // If already created disconnect cleanly
    try {
      if (_connected) {
        socket.dispose();
      }
    } catch (_) {}

    final options = IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableForceNew()
        .disableAutoConnect()
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .build();

    socket = IO.io('http://commv.skillupstream.com:5057/drivers', options);

    socket.onConnect((_) {
      _connected = true;
      log('✅ Connected (${socket.id})');
    });

    socket.onConnectError((err) {
      log('❌ Connect error: $err');
    });

    socket.onDisconnect((_) {
      _connected = false;
      log('🔌 Disconnected');
    });

    socket.on('driver:self:location', (data) {
      log('📦 self: $data');
    });

    socket.on('ride:driver:location', (data) {
      log('🚗 ride: $data');
    });

    socket.connect();
  }

  void joinRide(String rideId) {
    if (!_connected) {
      log('⚠️ not connected yet, will try to join after connect');
    }
    socket.emitWithAck('driver:ride:join', {'rideId': rideId}, ack: (ack) {
      log('🟢 join ack: $ack');
    });
  }

  void sendLocation({
    required double lat,
    required double lng,
    required int seq,
    required String rideId,
  }) {
    final payload = {
      'lat': lat,
      'lng': lng,
      'rideId': rideId,
      'ts': DateTime.now().millisecondsSinceEpoch,
      'seq': seq,
    };
    try {
      socket.emitWithAck('driver:location:update', payload, ack: (ack) {
        log('📍 loc ack: $ack');
      });
    } catch (e) {
      log('❌ emit error: $e');
    }
  }

  void log(String msg) {
    final line = '${DateTime.now().toIso8601String()}  $msg';
    logs.insert(0, line);
    print(line);
  }

  List<String> getLogSnapshot() => logs.toList();

  @override
  void onClose() {
    try {
      socket.dispose();
    } catch (_) {}
    super.onClose();
  }
}
