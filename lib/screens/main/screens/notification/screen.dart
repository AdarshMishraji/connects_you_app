import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  static const String routeName = '/notifications';

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: Text('Notifications'));
  }
}
