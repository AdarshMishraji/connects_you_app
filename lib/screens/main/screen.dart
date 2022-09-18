import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:connects_you/constants/customTheme.dart';
import 'package:connects_you/constants/widget.dart';
// import 'package:connects_you/providers/settings.dart';
import 'package:connects_you/screens/main/screens/account/screen.dart';
import 'package:connects_you/screens/main/screens/inbox/screen.dart';
import 'package:connects_you/screens/main/screens/notification/screen.dart';
import 'package:connects_you/screens/main/screens/users/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final List<Widget> screens = const [
    InboxScreen(),
    UsersScreen(),
    NotificationScreen(),
    AccountScreen(),
  ];
  int _screenIndex = 0;
  late final TabController _tabController = TabController(
      length: screens.length, vsync: this, initialIndex: _screenIndex);
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // DBProvider.deleteDB();
    // SecureStorage.instance.deleteAll();
    final theme = Theme.of(context);
    // final selectedThemeMode = Provider.of<Settings>(context).theme;
    final mediaQuery = MediaQuery.of(context);
    // final systemIconBrightness = selectedThemeMode == ThemeMode.light
    // ? Brightness.dark
    // : selectedThemeMode == ThemeMode.dark
    //     ? Brightness.light
    //     : mediaQuery.platformBrightness == Brightness.dark
    //         ? Brightness.light
    // : Brightness.dark;
    final List<Icon> icons = [
      Icon(Icons.chat_rounded,
          color: _screenIndex == 0 ? Colors.white : theme.primaryColorLight,
          size: mediaQuery.size.width * 0.08),
      Icon(Icons.people_alt_rounded,
          color: _screenIndex == 0 ? Colors.white : theme.primaryColorLight,
          size: mediaQuery.size.width * 0.08),
      Icon(Icons.notifications_active_rounded,
          color: _screenIndex == 1 ? Colors.white : theme.primaryColorLight,
          size: mediaQuery.size.width * 0.08),
      Icon(Icons.person_rounded,
          color: _screenIndex == 2 ? Colors.white : theme.primaryColorLight,
          size: mediaQuery.size.width * 0.08)
    ];
    final overLayStyle = SystemUiOverlayStyle(
      statusBarColor: theme.backgroundColor,
      systemNavigationBarColor: theme.backgroundColor,
      // statusBarBrightness: systemIconBrightness,
      // statusBarIconBrightness: systemIconBrightness,
      // systemNavigationBarIconBrightness: systemIconBrightness,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overLayStyle,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: theme.backgroundColor,
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: screens,
        ),
        bottomNavigationBar: CircleNavBar(
          initIndex: _screenIndex,
          color: theme.cardColor,
          height: mediaQuery.size.height * 0.08,
          circleWidth: mediaQuery.size.height * 0.07,
          onChanged: (index) {
            _tabController.animateTo(index);
            setState(() {
              _screenIndex = index;
            });
          },
          inactiveIcons: icons,
          activeIcons: icons,
          gradient: const LinearGradient(colors: CustomTheme.gradientColors),
          shadowColor: const Color.fromRGBO(0, 100, 255, 2),
          elevation: 5,
          padding: const EdgeInsets.all(WidgetConstants.spacing_xs),
          cornerRadius: const BorderRadius.only(
            topLeft: Radius.circular(WidgetConstants.spacing_sm),
            topRight: Radius.circular(WidgetConstants.spacing_sm),
            bottomRight: Radius.circular(WidgetConstants.spacing_xxxl),
            bottomLeft: Radius.circular(WidgetConstants.spacing_xxxl),
          ),
        ),
      ),
    );
  }
}
