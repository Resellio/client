class ApiEndpoints {
  static const String baseUrl =
      'https://resellio-cfeug9cwgxe4fhcy.northeurope-01.azurewebsites.net/api';
  static const String admins = 'Admins';
  static const String customers = 'Customers';
  static const String organizers = 'Organizers';
  static const String categories = 'Categories';
  static const String events = 'Events';
  static const String shoppingCarts = 'ShoppingCarts';
  static const String checkout = '$shoppingCarts/checkout';
  static const String checkoutDue = '$shoppingCarts/due';
  static const String tickets = 'Tickets';
  static const String organizerEvents = '$events/organizer';
  static const String adminGoogleLogin = '$admins/google-login';
  static const String customerGoogleLogin = '$customers/google-login';
  static const String organizerGoogleLogin = '$organizers/google-login';
  static const String organizerAboutMe = '$organizers/about-me';
  static const String organizerVerify = '$organizers/verify';
}
