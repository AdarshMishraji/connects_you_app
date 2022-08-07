import 'package:connects_you/constants/customTheme.dart';
import 'package:connects_you/providers/auth.dart';
import 'package:connects_you/providers/settings.dart';
import 'package:connects_you/screens/main/screen.dart';
import 'package:connects_you/screens/main/screens/account/screen.dart';
import 'package:connects_you/screens/main/screens/chatRoom/screen.dart';
import 'package:connects_you/screens/main/screens/inbox/screen.dart';
import 'package:connects_you/screens/main/screens/notification/screen.dart';
import 'package:connects_you/screens/splash/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class Root extends StatelessWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
        ChangeNotifierProvider(create: (_) => Settings())
      ],
      child: Consumer<Settings>(
        builder: (_, settings, __) {
          final currentThemeMode =
              SchedulerBinding.instance.window.platformBrightness ==
                      Brightness.light
                  ? ThemeMode.light
                  : ThemeMode.dark;
          return MaterialApp(
            home: const SplashScreen(),
            themeMode: settings.theme == ThemeMode.system
                ? currentThemeMode
                : settings.theme,
            debugShowCheckedModeBanner: false,
            theme: CustomTheme.lightTheme,
            darkTheme: CustomTheme.darkTheme,
            routes: {
              SplashScreen.routeName: (_) => const SplashScreen(),
              MainScreen.routeName: (_) => const MainScreen(),
              AccountScreen.routeName: (_) => const AccountScreen(),
              ChatRoomScreen.routeName: (_) => const ChatRoomScreen(),
              InboxScreen.routeName: (_) => const InboxScreen(),
              NotificationScreen.routeName: (_) => const NotificationScreen(),
            },
          );
        },
      ),
    );
  }
}
