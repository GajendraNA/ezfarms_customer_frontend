import 'package:shared_preferences/shared_preferences.dart';

const String defaultIpAddress = '172.24.239.38';
const String defaultPort = '8080';

const _ipKey = 'serverIp';
const _portKey = 'serverPort';

// The server address can be changed from the login screen, so it is not
// hard-coded: handy when the backend machine's IP changes between networks.
String ipAddress = defaultIpAddress;
String port = defaultPort;

Future<void> loadServerAddress() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    ipAddress = prefs.getString(_ipKey) ?? defaultIpAddress;
    port = prefs.getString(_portKey) ?? defaultPort;
  } catch (_) {
    // Keep the defaults if preferences can't be read.
  }
}

Future<void> saveServerAddress(String ip, String newPort) async {
  ipAddress = ip.trim();
  port = newPort.trim();
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_ipKey, ipAddress);
  await prefs.setString(_portKey, port);
}

String apiUrl(String endpoint) {
  return 'http://$ipAddress:$port/api/$endpoint';
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
  return 'http://$ipAddress:$port/${imagePath ?? ''}';
}
