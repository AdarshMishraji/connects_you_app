import 'package:connects_you/constants/widget.dart';
import 'package:connects_you/logic/auth/auth.dart';
import 'package:connects_you/logic/auth/auth_events.dart';
import 'package:connects_you/logic/auth/auth_states.dart';
import 'package:connects_you/screens/main/screen.dart';
// import 'package:connects_you/providers/auth.dart';
// import 'package:connects_you/screens/main/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({Key? key}) : super(key: key);

  Future _onAuthButtonClick(BuildContext context) async {
    try {
      // await DBProvider.deleteDB();
      // await SecureStorage.instance.deleteAll();
      // await DBProvider.getDB();
      // return;
      context.read<AuthBloc>().add(const AuthenticateAuthEvent());
      context.read<AuthBloc>().state.authenticatedUser != null
          ? Navigator.of(context).pushReplacementNamed(MainScreen.routeName)
          : null;
    } catch (error) {
      debugPrint('authenticationError $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: WidgetConstants.spacing_sm),
      child: Column(
        children: [
          InkWell(
            highlightColor: Colors.black54,
            borderRadius: BorderRadius.circular(WidgetConstants.spacing_xxl),
            onTap: context.read<AuthBloc>().state is InProgressAuthState
                ? null
                : () => _onAuthButtonClick(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: WidgetConstants.spacing_sm),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // if (authProvider.authState == AuthStates.inProgress)
                  //   CupertinoActivityIndicator(
                  //     color: theme.primaryColor,
                  //     radius: 20,
                  //   )
                  // else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/svgs/google.svg',
                        height: 30,
                        width: 30,
                      ),
                      const SizedBox(
                        width: WidgetConstants.spacing_xxxl,
                      ),
                      Text(
                        'Login with Google',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: WidgetConstants.spacing_xxxl),
            child: Text(
              // authProvider.authStateMessage ?? 'sfhgdfxjb',
              "dsfbgdn",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: theme.primaryColor.withOpacity(0.5), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
