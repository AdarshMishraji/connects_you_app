import 'package:connects_you/theme/app_theme.dart';
import 'package:connects_you/data/models/setting.dart';
import 'package:connects_you/logic/auth/auth.dart';
import 'package:connects_you/logic/settings/settings.dart';
import 'package:connects_you/logic/socket/socket.dart';
import 'package:connects_you/repository/gDriveOps/g_drive_ops.dart';
import 'package:connects_you/repository/localDB/db_ops.dart';
import 'package:connects_you/repository/localDB/shared_keys_ops.dart';
import 'package:connects_you/repository/localDB/user_ops.dart';
import 'package:connects_you/repository/secureStorage/secure_storage.dart';
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

  Widget repositoryProviders({required Widget child}) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => SecureStorageRepository()),
        RepositoryProvider(create: (_) => DBOpsRepository()),
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => UserOpsRepository()),
        RepositoryProvider(create: (_) => GDriveOpsRepository()),
        RepositoryProvider(create: (_) => SharedKeysOpsRepository()),
      ],
      child: child,
    );
  }

  Widget blocProviders({required Widget child}) {
    return MultiBlocProvider(
      providers: [
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
      ],
      child: child,
    );
  }

  Widget app() {
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
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
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
    return repositoryProviders(
      child: blocProviders(
        child: app(),
      ),
    );
  }
}
