import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:connects_you/constants/customTheme.dart';
import 'package:connects_you/constants/widget.dart';
import 'package:connects_you/providers/settings.dart';
import 'package:connects_you/screens/main/screens/account/screen.dart';
import 'package:connects_you/screens/main/screens/inbox/screen.dart';
import 'package:connects_you/screens/main/screens/notification/screen.dart';
import 'package:connects_you/screens/main/widgets/userSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _screenIndex = 0;
  late final TabController _tabController =
      TabController(length: 3, vsync: this, initialIndex: _screenIndex);
  bool _showUserList = false;
  final ScrollController _scrollController = ScrollController();

  final List<Widget> screens = const [
    InboxScreen(),
    NotificationScreen(),
    AccountScreen(),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showBottomSheet() {
    final mediaQuery = MediaQuery.of(context);
    _scrollController.animateTo(mediaQuery.size.height * 0.9,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubicEmphasized);
    setState(() {
      _showUserList = true;
    });
  }

  void _closeBottomSheet() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubicEmphasized);
    setState(() {
      _showUserList = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // DBProvider.deleteDB();
    // SecureStorage.instance.deleteAll();
    final theme = Theme.of(context);
    final selectedThemeMode = Provider.of<Settings>(context).theme;
    final mediaQuery = MediaQuery.of(context);
    final systemIconBrightness = selectedThemeMode == ThemeMode.light
        ? Brightness.dark
        : selectedThemeMode == ThemeMode.dark
            ? Brightness.light
            : mediaQuery.platformBrightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark;
    final List<Icon> icons = [
      Icon(Icons.chat_rounded,
          color: _screenIndex == 0 ? Colors.white : theme.primaryColorLight,
          size: mediaQuery.size.width * 0.09),
      Icon(Icons.notifications_active_rounded,
          color: _screenIndex == 1 ? Colors.white : theme.primaryColorLight,
          size: mediaQuery.size.width * 0.09),
      Icon(Icons.person_rounded,
          color: _screenIndex == 2 ? Colors.white : theme.primaryColorLight,
          size: mediaQuery.size.width * 0.09)
    ];
    final overLayStyle = SystemUiOverlayStyle(
      statusBarColor: theme.backgroundColor,
      systemNavigationBarColor: theme.backgroundColor,
      statusBarBrightness: systemIconBrightness,
      statusBarIconBrightness: systemIconBrightness,
      systemNavigationBarIconBrightness: systemIconBrightness,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overLayStyle,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _scrollController,
        child: Column(
          children: [
            GestureDetector(
              onTap: _showUserList ? _closeBottomSheet : null,
              child: SizedBox(
                height: mediaQuery.size.height,
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: theme.backgroundColor,
                  body: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: screens,
                  ),
                  floatingActionButton: _screenIndex == 0
                      ? Container(
                          padding: const EdgeInsets.all(
                              WidgetConstants.spacing_xxxs),
                          decoration: BoxDecoration(
                              color: const Color.fromRGBO(0, 100, 255, 2),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 100, 255, 2),
                                  blurRadius: 7.5,
                                  spreadRadius: 0.5,
                                )
                              ]),
                          child: IconButton(
                            icon: const Icon(
                              Icons.people_alt_rounded,
                              size: 28,
                            ),
                            color: theme.primaryColorLight,
                            onPressed: !_showUserList ? _showBottomSheet : null,
                          ),
                        )
                      : null,
                  bottomNavigationBar: AbsorbPointer(
                    absorbing: _showUserList,
                    child: CircleNavBar(
                      initIndex: _screenIndex,
                      color: theme.cardColor,
                      height: 60,
                      onChanged: (index) {
                        _tabController.animateTo(index);
                        setState(() {
                          _screenIndex = index;
                        });
                      },
                      inactiveIcons: icons,
                      activeIcons: icons,
                      gradient: const LinearGradient(
                          colors: CustomTheme.gradientColors),
                      shadowColor: const Color.fromRGBO(0, 100, 255, 2),
                      elevation: 5,
                      padding: const EdgeInsets.all(WidgetConstants.spacing_xs),
                      cornerRadius: const BorderRadius.only(
                        topLeft: Radius.circular(WidgetConstants.spacing_sm),
                        topRight: Radius.circular(WidgetConstants.spacing_sm),
                        bottomRight:
                            Radius.circular(WidgetConstants.spacing_xxxl),
                        bottomLeft:
                            Radius.circular(WidgetConstants.spacing_xxxl),
                      ),
                      circleWidth: 60,
                    ),
                  ),
                ),
              ),
            ),
            UserSheet(
              onClose: _closeBottomSheet,
            ),
          ],
        ),
      ),
    );
  }
}
