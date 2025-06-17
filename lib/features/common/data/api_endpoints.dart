class ApiEndpoints {
  static const String baseUrl =
      'https://resellio-cfeug9cwgxe4fhcy.northeurope-01.azurewebsites.net/api';
  static const String admins = 'Admins';
  static const String customers = 'Customers';
  static const String organizers = 'Organizers';
  static const String categories = 'Categories';
  static const String events = 'Events';
  static const String shoppingCarts = 'ShoppingCarts';
  static const String tickets = 'Tickets';

  static const String adminGoogleLogin = '$admins/google-login';
  static const String customerGoogleLogin = '$customers/google-login';
  static const String organizerGoogleLogin = '$organizers/google-login';

  static const String organizerEvents = '$events/organizer';
  static const String organizerAboutMe = '$organizers/about-me';
  static const String customerAboutMe = '$customers/about-me';
  static const String organizerVerify = '$organizers/verify';
  static const String organizersUnverified = '$organizers/unverified';

  static const String checkout = '$shoppingCarts/checkout';
  static const String checkoutDue = '$shoppingCarts/due';

  static const String ticketsResell = '$tickets/resell';
  static const String ticketsForResell = '$tickets/for-resell';

  static String eventDetails(String eventId) => '$events/$eventId';
  static String organizerEventDetails(String eventId) =>
      '$organizerEvents/$eventId';
  static String updateEvent(String eventId) => '$events/$eventId';
  static String ticketDetails(String ticketId) => '$tickets/$ticketId';
  static String resellTicket(String ticketId) => '$ticketsResell/$ticketId';
  static String addResellTicketToCart(String ticketId) =>
      '$shoppingCarts/$ticketId';
  static String removeResellTicketFromCart(String ticketId) =>
      '$shoppingCarts/$ticketId';

  static String fullUrl(String endpoint) => '$baseUrl/$endpoint';
}
