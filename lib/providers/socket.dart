import 'package:connects_you/constants/keys.dart';
import 'package:connects_you/constants/url.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum SocketConnectionState { connected, connecting, disconnected }

class SocketOps with ChangeNotifier {
  late IO.Socket socket;
  late final String token;
  SocketConnectionState socketState = SocketConnectionState.disconnected;

  _initializeSocket() {
    socket = IO.io(
        URLs.baseURL,
        IO.OptionBuilder()
            .setAuth({
              'token': token,
              'key': Keys.API_KEY,
            })
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(2000)
            .setReconnectionDelayMax(10000)
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    _addListeners();
    socket.connect();
  }

  _addListeners() {
    socket.onConnecting((_) {
      debugPrint('connecting');
      socketState = SocketConnectionState.connecting;
      notifyListeners();
    });
    socket.onConnect((_) {
      debugPrint('Connected');
      socketState = SocketConnectionState.connected;
      notifyListeners();
    });
    socket.onReconnectAttempt((_) {
      debugPrint('connecting');
      socketState = SocketConnectionState.connecting;
      notifyListeners();
    });
    socket.onReconnecting((_) {
      debugPrint('connecting');
      socketState = SocketConnectionState.connecting;
      notifyListeners();
    });
    socket.onReconnect((_) {
      debugPrint('connected');
      socketState = SocketConnectionState.connected;
      notifyListeners();
    });
    socket.onDisconnect((_) async {
      socket.clearListeners();
      socket.connect();
      if (socket.connected) {
        socketState = SocketConnectionState.connected;
        socket.emit('ping', 'pinged');
      } else {
        socket.dispose();
        debugPrint('disconnected');
        socketState = SocketConnectionState.disconnected;
        await Future.delayed(const Duration(seconds: 1));
        _initializeSocket();
      }
      notifyListeners();
    });
  }

  SocketOps(this.token) {
    _initializeSocket();
  }
}
