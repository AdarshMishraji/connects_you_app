import 'package:connects_you/data/models/user.dart';

class AuthStatesMessages {
  static const String fetchingYourPrevSession =
      'Fetching Your Previous Session';
  static const String sessionRetrieved = 'Session Retrieved';
  static const String sessionNotRetrieved =
      'Session Not Retrieved\nKindly authenticate yourself';
  static const String authenticatingYou = 'Authenticating You';
  static const String savingYourDetails =
      '$creatingYourAccount${'\n'}Saving Your Details';
  static const String savingLocalKeys = '$authenticatingYou${'\n'}Saving Keys';
  static const String creatingYourAccount = 'Creating Your Account';
  static const String savingDriveKeys =
      '$creatingYourAccount${'\n'}Saving Keys';
  static const String fetchingAndSavingYourPrevData =
      '$authenticatingYou${'\n'}Fetching And Saving Your Previous Data';
  static const String authCompleted = 'Authentication Process Completed';
  static const String authError = 'Authentication Process Failed';
}

abstract class AuthStates {
  final String? authStateMessage;
  final AuthenticatedUser? authenticatedUser;
  const AuthStates({this.authStateMessage, this.authenticatedUser});
}

class NotStartedAuthState extends AuthStates {
  const NotStartedAuthState();
}

class StartedAuthState extends AuthStates {
  const StartedAuthState();
}

class InProgressAuthState extends AuthStates {
  const InProgressAuthState({required String authStateMessage})
      : super(
          authStateMessage: authStateMessage,
        );
}

class CompletedAuthState extends AuthStates {
  const CompletedAuthState({
    required String authStateMessage,
    AuthenticatedUser? authenticatedUser,
  }) : super(
          authStateMessage: authStateMessage,
          authenticatedUser: authenticatedUser,
        );
}
