import 'package:connects_you/data/models/user.dart';

enum AuthMethod {
  none('none'),
  signup('Signup'),
  login('Login');

  const AuthMethod(this.value);
  final String value;
}

class AuthenticatedServerUser extends User {
  final String token;
  final AuthMethod method;

  const AuthenticatedServerUser({
    required String userId,
    required String name,
    required String email,
    required String photo,
    required String publicKey,
    required this.method,
    required this.token,
  }) : super(
          email: email,
          userId: userId,
          name: name,
          photo: photo,
          publicKey: publicKey,
        );
}
