import 'package:flutter/material.dart';

class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({Key? key}) : super(key: key);

  static const String routeName = '/chatRoom';

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: Text('Chat room'));
  }
}
