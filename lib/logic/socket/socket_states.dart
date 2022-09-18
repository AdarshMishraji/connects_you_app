import 'package:socket_io_client/socket_io_client.dart';

abstract class SocketStates {
  const SocketStates();
}

class SocketConnected extends SocketStates {
  final Socket socket;
  const SocketConnected({required this.socket});
}

class SocketDisconnected extends SocketStates {
  const SocketDisconnected();
}

class SocketConnecting extends SocketStates {
  const SocketConnecting();
}
