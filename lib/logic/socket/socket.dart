import 'package:connects_you/constants/keys.dart';
import 'package:connects_you/constants/url.dart';
import 'package:connects_you/logic/socket/socket_events.dart';
import 'package:connects_you/logic/socket/socket_states.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketBloc extends Bloc<SocketEvents, SocketStates> {
  late Socket socket;

  SocketBloc() : super(const SocketDisconnected()) {
    on<InitializeSocket>(_initializeSocket);
    on<DisconnectSocket>(_disconnectSocket);
  }

  void _initializeSocket(InitializeSocket event, Emitter emit) {
    socket = io(
        URLs.baseURL,
        OptionBuilder()
            .setAuth({
              'token': event.token,
              'key': Keys.API_KEY,
            })
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(2000)
            .setReconnectionDelayMax(10000)
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    _addListeners(event, emit);
    socket.connect();
  }

  void _addListeners(InitializeSocket event, Emitter emit) {
    socket.onConnecting((_) {
      debugPrint('connecting');
      emit(const SocketConnecting());
    });
    socket.onConnect((_) {
      debugPrint('Connected');
      emit(SocketConnected(socket: socket));
    });
    socket.onReconnectAttempt((_) {
      debugPrint('connecting');
      emit(const SocketConnecting());
    });
    socket.onReconnecting((_) {
      debugPrint('connecting');
      emit(const SocketConnecting());
    });
    socket.onReconnect((_) {
      debugPrint('connected');
      emit(SocketConnected(socket: socket));
    });
    socket.onDisconnect((_) async {
      socket.clearListeners();
      socket.connect();
      if (socket.connected) {
        emit(SocketConnected(socket: socket));
        socket.emit('ping', 'pinged');
      } else {
        socket.dispose();
        debugPrint('disconnected');
        emit(const SocketDisconnected());
        await Future.delayed(const Duration(seconds: 1));
        emit(const SocketDisconnected());
        _initializeSocket(event, emit);
      }
    });
  }

  void _disconnectSocket(DisconnectSocket _, Emitter emit) {
    socket.dispose();
    emit(const SocketDisconnected());
  }
}
