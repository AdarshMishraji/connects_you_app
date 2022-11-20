class GeoData {
  final String status;
  final String message;
  final String continent;
  final String continentCodes;
  final String country;
  final String countryCode;
  final String region;
  final String regionName;
  final String city;
  final String zip;
  final String lat;
  final String lon;
  final String timezone;
  final String offset;
  final String currency;
  final String isp;
  final String org;
  final String as;
  final String asname;
  final String reverse;
  final String mobile;
  final String proxy;
  final String hosting;
  final String query;

  const GeoData({
    required this.status,
    required this.message,
    required this.continent,
    required this.continentCodes,
    required this.country,
    required this.countryCode,
    required this.region,
    required this.regionName,
    required this.city,
    required this.zip,
    required this.lat,
    required this.lon,
    required this.timezone,
    required this.offset,
    required this.currency,
    required this.isp,
    required this.org,
    required this.as,
    required this.asname,
    required this.reverse,
    required this.mobile,
    required this.proxy,
    required this.hosting,
    required this.query,
  });
}

class ClientMetaData {
  final String ip;
  final String userAgent;
  final GeoData geoData;

  ClientMetaData({
    required this.ip,
    required this.userAgent,
    required this.geoData,
  });
}

class UserLoginInfo {
  final String userId;
  final String loginId;
  final bool isValid;
  final ClientMetaData loginMetaData;
  final DateTime createdAt;

  const UserLoginInfo({
    required this.userId,
    required this.loginId,
    required this.isValid,
    required this.loginMetaData,
    required this.createdAt,
  });
}
