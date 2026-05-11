import 'api_client.dart';

class OrderService {
  // Calls POST /api/orders/checkout using the server-side cart.
  // Returns the order map: { id, itemsTotal, discount, tax, deliveryCharge, totalPay, status, createdAt }
  static Future<Map<String, dynamic>> checkout() async {
    final data =
        await ApiClient.post('/api/orders/checkout', {}) as Map<String, dynamic>;
    return data['order'] as Map<String, dynamic>;
  }
}
