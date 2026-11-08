import 'package:shared_preferences/shared_preferences.dart';

// Default backend address. Set it when building the app, for example:
//   flutter build apk --dart-define=API_BASE_URL=https://ez-farms.onrender.com
//   flutter build apk --dart-define=API_BASE_URL=http://203.0.113.25:8080
// Without it, the app uses the local development server below.
const String defaultServerUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://172.24.239.38:8080',
);

const _urlKey = 'serverUrl';

// The server address can also be changed from the login screen, which is
// handy when testing against a machine whose IP changes between networks.
String serverUrl = normalizeServerUrl(defaultServerUrl);

/// Accepts "1.2.3.4:8080", "http://1.2.3.4:8080" or "https://my-host.com/"
/// and returns it with a scheme and without a trailing slash.
String normalizeServerUrl(String input) {
  var url = input.trim();
  if (url.isEmpty) url = defaultServerUrl;
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'http://$url';
  }
  while (url.endsWith('/')) {
    url = url.substring(0, url.length - 1);
  }
  return url;
}

Future<void> loadServerAddress() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    serverUrl = normalizeServerUrl(prefs.getString(_urlKey) ?? defaultServerUrl);
  } catch (_) {
    // Keep the default if preferences can't be read.
  }
}

Future<void> saveServerAddress(String url) async {
  serverUrl = normalizeServerUrl(url);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_urlKey, serverUrl);
}

String apiUrl(String endpoint) {
  return '$serverUrl/api/$endpoint';
}

String get getAllOrdersUrl => apiUrl('orders');
String get getAllCustomersUrl => apiUrl('buyer');
String get getAllFarmersUrl => apiUrl('farmer');
String get getAllInventoryUrl => apiUrl('inventory');
String get getAllItemsUrl => apiUrl('items');
String get postOrderUrl => apiUrl('orders');
String get updateInventoryUrl => apiUrl('bInventory');
String get loginUrl => apiUrl('buyerLogin');
String get registerUrl => apiUrl('buyerRegister');
String get getAllPayments => apiUrl('payment');
String buyerOrdersUrl(int buyerId) => apiUrl('bOrders/$buyerId');
String buyerPaymentsUrl(int buyerId) => apiUrl('bPayment/$buyerId');

String getImageUrl(String? imagePath) {
  return '$serverUrl/${imagePath ?? ''}';
}
