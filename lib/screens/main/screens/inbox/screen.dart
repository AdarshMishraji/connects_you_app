import 'package:connects_you/constants/locale.dart';
import 'package:flutter/material.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({Key? key}) : super(key: key);

  static const String routeName = '/inbox';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        // color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo.png',
            ),
            const Text(
              Locale.appName,
            )
          ],
        ),
      ),
    );
  }
}
