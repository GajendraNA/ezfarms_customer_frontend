final String ipAddress = 'localhost';

final String port = '8080';

String apiUrl(String endpoint) {
  return 'http://$ipAddress:$port/api/$endpoint';
}

final String getAllOrdersUrl = apiUrl('orders');
final String getAllCustomersUrl = apiUrl('buyer');
final String getAllFarmersUrl = apiUrl('farmer');
final String getAllInventoryUrl = apiUrl('inventory');
final String getAllItemsUrl = apiUrl('items');
final String createOrderUrl = apiUrl('orders');
final String postOrderUrl = apiUrl('orders');
final String updateInventoryUrl = apiUrl('bInventory');
final String loginUrl = apiUrl('buyerLogin');
final String registerUrl = apiUrl('buyerRegister');
final String getAllInventory = apiUrl('inventory');
final String postInventory = apiUrl('inventory');
final String getAllPayments = apiUrl('payment');

String getImageUrl(String imagePath) {
  return 'http://$ipAddress:$port/$imagePath';
}
