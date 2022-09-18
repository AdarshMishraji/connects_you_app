import 'package:connects_you/constants/customTheme.dart';
import 'package:connects_you/data/models/setting.dart';
import 'package:connects_you/logic/auth/auth.dart';
import 'package:connects_you/logic/settings/settings.dart';
import 'package:connects_you/logic/socket/socket.dart';
import 'package:connects_you/repository/gDriveOps/gDriveOps.dart';
import 'package:connects_you/repository/localDB/DBOps.dart';
import 'package:connects_you/repository/localDB/sharedKeysOps.dart';
import 'package:connects_you/repository/localDB/userOps.dart';
import 'package:connects_you/repository/secureStorage/secureStorage.dart';
import 'package:connects_you/repository/server/auth.dart';
import 'package:connects_you/screens/main/screen.dart';
import 'package:connects_you/screens/main/screens/account/screen.dart';
import 'package:connects_you/screens/main/screens/chatRoom/screen.dart';
import 'package:connects_you/screens/main/screens/inbox/screen.dart';
import 'package:connects_you/screens/main/screens/notification/screen.dart';
import 'package:connects_you/screens/main/screens/users/screen.dart';
import 'package:connects_you/screens/splash/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Root extends StatelessWidget {
  const Root({Key? key}) : super(key: key);

  Widget RepositoryProviders({required Widget child}) {
    return MultiRepositoryProvider(providers: [
      RepositoryProvider(create: (_) => const SecureStorageRepository()),
      RepositoryProvider(create: (_) => DBOpsRepository()),
      RepositoryProvider(create: (_) => const AuthRepository()),
      RepositoryProvider(create: (_) => const UserOpsRepository()),
      RepositoryProvider(create: (_) => const GDriveOpsRepository()),
      RepositoryProvider(create: (_) => const SharedKeysOpsRepository()),
    ], child: child);
  }

  Widget BlocProviders({required Widget child}) {
    return MultiBlocProvider(providers: [
      BlocProvider(
        create: (ctx) => SettingsBloc(
          secureStorageRepository: ctx.read<SecureStorageRepository>(),
        ),
      ),
      BlocProvider(
        create: (ctx) => AuthBloc(
            authRepository: ctx.read<AuthRepository>(),
            userOpsRepository: ctx.read<UserOpsRepository>(),
            gDriveOpsRepository: ctx.read<GDriveOpsRepository>(),
            sharedKeysOpsRepository: ctx.read<SharedKeysOpsRepository>(),
            dbOpsRepository: ctx.read<DBOpsRepository>(),
            secureStorageRepository: ctx.read<SecureStorageRepository>()),
      ),
      BlocProvider(create: (ctx) => SocketBloc())
    ], child: child);
  }

  Widget App() {
    return BlocBuilder<SettingsBloc, Setting>(builder: (context, settings) {
      final currentThemeMode =
          SchedulerBinding.instance.window.platformBrightness ==
                  Brightness.light
              ? ThemeMode.light
              : ThemeMode.dark;
      return MaterialApp(
        home: const SplashScreen(),
        themeMode: settings.themeMode == ThemeMode.system
            ? currentThemeMode
            : settings.themeMode,
        debugShowCheckedModeBanner: false,
        theme: CustomTheme.lightTheme,
        darkTheme: CustomTheme.darkTheme,
        routes: {
          SplashScreen.routeName: (_) => const SplashScreen(),
          MainScreen.routeName: (_) => const MainScreen(),
          UsersScreen.routeName: (_) => const UsersScreen(),
          AccountScreen.routeName: (_) => const AccountScreen(),
          ChatRoomScreen.routeName: (_) => const ChatRoomScreen(),
          InboxScreen.routeName: (_) => const InboxScreen(),
          NotificationScreen.routeName: (_) => const NotificationScreen(),
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProviders(
      child: BlocProviders(
        child: App(),
      ),
    );
  }
}
