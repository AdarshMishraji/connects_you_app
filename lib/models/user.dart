class User {
  final String userId;
  final String name;
  final String email;
  final String? photo;
  final String publicKey;

  const User({
    required this.userId,
    required this.name,
    required this.email,
    this.photo,
    required this.publicKey,
  });
}

class AuthenticatedUser extends User {
  final String privateKey;
  final String token;

  const AuthenticatedUser({
    required String userId,
    required String name,
    required String email,
    String? photo,
    required String publicKey,
    required this.privateKey,
    required this.token,
  }) : super(
          email: email,
          userId: userId,
          name: name,
          photo: photo,
          publicKey: publicKey,
        );

  @override
  String toString() {
    return 'userId:$userId, name:$name, email:$email, photo:$photo, publicKey:$publicKey, privateKey:$privateKey, token:$token';
  }
}

class LocalDBUser extends User {
  final String? privateKey;

  const LocalDBUser({
    required String userId,
    required String name,
    required String email,
    String? photo,
    required String publicKey,
    this.privateKey,
  }) : super(
          email: email,
          userId: userId,
          name: name,
          photo: photo,
          publicKey: publicKey,
        );

  @override
  String toString() {
    return 'userId:$userId, name:$name, email:$email, photo:$photo, publicKey:$publicKey, privateKey:$privateKey';
  }
}
