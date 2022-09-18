abstract class AuthEvents {
  const AuthEvents();
}

class AuthenticateAuthEvent extends AuthEvents {
  const AuthenticateAuthEvent();
}

class FetchAuthenticatedUser extends AuthEvents {
  const FetchAuthenticatedUser();
}

class SignoutAuthEvent extends AuthEvents {
  final String token;
  const SignoutAuthEvent({required this.token});
}
