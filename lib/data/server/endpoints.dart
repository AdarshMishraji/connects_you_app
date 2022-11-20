class Endpoints {
  static const String _auth = '/auth';
  static const String _user = '/user';
  static const String _room = '/room';

  static const String authenticate = '${Endpoints._auth}/authenticate';
  static const String signout = '${Endpoints._auth}/signout';
  static const String updateFcmToken = '${Endpoints._auth}/fcm-token';
  static const String refreshToken = '${Endpoints._auth}/refresh-token';
  static const String currentLoginInfo =
      '${Endpoints._auth}/current-login-info';
  static const String myLoginHistory = '${Endpoints._auth}/my-login-history';

  static const userDetails = '${Endpoints._user}/user-details';
  static const allUsers = '${Endpoints._user}/all-users';
  static const myDetails = '${Endpoints._user}/my-details';

  static const String allRooms = '${Endpoints._room}/rooms';
  // static const String cachedData = '${Endpoints.me}/cached_data';
}
