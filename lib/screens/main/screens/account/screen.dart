import 'package:connects_you/constants/locale.dart';
// import 'package:connects_you/providers/auth.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  static const String routeName = '/account';

  void _onLogoutPress(BuildContext context) async {
    try {
      // await Provider.of<Auth>(context, listen: false).signout().then((value) =>
      //     Navigator.of(context).pushReplacementNamed(SplashScreen.routeName));
    } catch (error) {
      debugPrint('$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => _onLogoutPress(context),
            icon: const Icon(Icons.logout),
            label: const Text(Locale.logout),
          ),
        ],
      ),
    );
  }
}
