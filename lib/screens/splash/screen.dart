import 'package:connects_you/constants/locale.dart';
import 'package:connects_you/constants/widget.dart';
import 'package:connects_you/logic/auth/auth.dart';
import 'package:connects_you/logic/auth/auth_events.dart';
import 'package:connects_you/logic/settings/settings.dart';
import 'package:connects_you/repository/localDB/DBOps.dart';
import 'package:connects_you/screens/main/screen.dart';
import 'package:connects_you/screens/splash/authButton.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ConnectionState _futureState = ConnectionState.none;
  bool? _isAuthenticated;

  Future _fetchAuthState() async {
    setState(() {
      _futureState = ConnectionState.waiting;
    });
    Firebase.apps.isNotEmpty ? null : await Firebase.initializeApp();
    if (!mounted) return;
  
    context.read<AuthBloc>().add(const FetchAuthenticatedUser());
    final isAuthenticated =
        context.read<AuthBloc>().state.authenticatedUser != null;

    await Future.delayed(WidgetConstants.slowAnimation);
    setState(() {
      _futureState = ConnectionState.done;
      _isAuthenticated = isAuthenticated;
    });
    if (isAuthenticated) {
      Future.delayed(WidgetConstants.normalAnimation).then(
        (_) => isAuthenticated
            ? Navigator.of(context).pushNamed(MainScreen.routeName)
            : null,
      );
    }
  }

  @override
  void initState() {
    print('splash init');
    if (mounted) {
      Future.delayed(WidgetConstants.slowAnimation).then((_) async {
        await context.read<DBOpsRepository>().initialiseDB();
        await _fetchAuthState();
      }).catchError((error) {
        debugPrint('$error');
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedThemeMode = context.watch<SettingsBloc>().state.themeMode;
    final mediaQuery = MediaQuery.of(context);
    final systemIconBrightness = selectedThemeMode == ThemeMode.light
        ? Brightness.dark
        : selectedThemeMode == ThemeMode.dark
            ? Brightness.light
            : mediaQuery.platformBrightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark;
    final overLayStyle = SystemUiOverlayStyle(
      statusBarColor: theme.backgroundColor,
      systemNavigationBarColor: theme.backgroundColor,
      statusBarBrightness: systemIconBrightness,
      statusBarIconBrightness: systemIconBrightness,
      systemNavigationBarIconBrightness: systemIconBrightness,
    );
    final containerHeight = _futureState == ConnectionState.done &&
            _isAuthenticated != null &&
            _isAuthenticated == false
        ? mediaQuery.size.width * 0.8 + 250
        : mediaQuery.size.width * 0.8 + 75;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overLayStyle,
      child: Scaffold(
        backgroundColor: theme.backgroundColor,
        body: Container(
          height: double.infinity,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: WidgetConstants.slowAnimation,
            transform: Transform.translate(
              offset: _futureState == ConnectionState.none
                  ? Offset(0, mediaQuery.size.height)
                  : _futureState == ConnectionState.waiting
                      ? WidgetConstants.offset00
                      : _isAuthenticated != null && _isAuthenticated == true
                          ? Offset(-mediaQuery.size.width, 0)
                          : WidgetConstants.offset00,
            ).transform,
            height: containerHeight,
            width: double.infinity,
            curve: Curves.easeInOutCubicEmphasized,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: mediaQuery.size.width * 0.8,
                    height: mediaQuery.size.width * 0.8,
                  ),
                  Text(
                    Locale.appName,
                    style: theme.textTheme.titleLarge!.copyWith(fontSize: 32),
                  ),
                  AnimatedContainer(
                    height: _futureState == ConnectionState.done &&
                            _isAuthenticated != null &&
                            _isAuthenticated == false
                        ? 250
                        : 0,
                    margin: const EdgeInsets.all(WidgetConstants.spacing_sm),
                    curve: Curves.easeIn,
                    duration: WidgetConstants.normalAnimation,
                    child: const AuthButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
