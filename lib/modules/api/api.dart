class API {
  static String jwt = '';

  static set token(String token) {
    jwt = token;
  }

  static String get token {
    return jwt;
  }
}
