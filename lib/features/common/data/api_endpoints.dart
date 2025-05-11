class ApiEndpoints {
  static const String baseUrl =
      // 'https://resellio-cfeug9cwgxe4fhcy.northeurope-01.azurewebsites.net/api';
      'http://localhost:5124/api';
  static const String customers = 'Customers';
  static const String organizers = 'Organizers';
  static const String admins = 'Admins';
  static const String events = 'Events';
  static const String customerGoogleLogin = '$customers/google-login';
  static const String organizerGoogleLogin = '$organizers/google-login';
  static const String adminGoogleLogin = '$admins/google-login';
  static const String organizerAboutMe = '$organizers/about-me';
  static const String organizerVerify = '$organizers/verify';
}
