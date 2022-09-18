abstract class SocketEvents {
  const SocketEvents();
}

class InitializeSocket extends SocketEvents {
  final String token;
  const InitializeSocket({required this.token});
}

class DisconnectSocket extends SocketEvents {
  const DisconnectSocket();
}
