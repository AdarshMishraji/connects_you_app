import 'package:connects_you/data/models/user.dart';

class AuthenticatedServerUser extends User {
  final String token;
  final String method;

  const AuthenticatedServerUser({
    required String userId,
    required String name,
    required String email,
    required String photoUrl,
    required String publicKey,
    required this.method,
    required this.token,
  }) : super(
          email: email,
          userId: userId,
          name: name,
          photoUrl: photoUrl,
          publicKey: publicKey,
        );
}
