import 'package:flutter/material.dart';
import '../../services/order_service.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  String _formatPrice(double amount) {
    if (amount < 5000) {
      return "${amount.toInt()}\$";
    }
    String value = amount.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String Function(Match) mathFunc = (Match match) => '${match[1]}.';
    return "${value.replaceAllMapped(reg, mathFunc)}đ";
  }

  Widget _buildCardLogo(String cardType) {
    final lower = cardType.toLowerCase();
    if (lower.contains("mastercard")) {
      return SizedBox(
        width: 32,
        height: 20,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xffEB001B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 10,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xffF79E1B).withOpacity(0.85),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (lower.contains("visa")) {
      return const Text(
        "VISA",
        style: TextStyle(
          color: Color(0xff1A1F71),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      );
    } else {
      return const Icon(Icons.credit_card, color: Colors.grey, size: 18);
    }
  }

  Widget _buildInfoRow(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: valueWidget,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowText(String label, String value) {
    return _buildInfoRow(
      label,
      Text(
        value,
        style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xffDB3022);
    final orderService = OrderService();

    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Order Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: orderService.getOrderById(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Failed to load order details: ${snapshot.error}",
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          final order = snapshot.data!;
          final orderNum = order["orderNumber"] ?? "";
          final status = order["status"] ?? "PROCESSING";
          final total = order["totalAmount"] as double;
          final discount = order["discountAmount"] as double;
          final shippingAddress = order["shippingAddress"] ?? "";
          final paymentMethod = order["paymentMethod"] ?? "";
          final shippingMethod = order["shippingMethod"] ?? "FedEx";
          final items = order["items"] as List? ?? [];
          final dateStr = order["orderDate"] != null
              ? order["orderDate"].toString().substring(0, 10)
              : "";

          // Extract last 4 digits & type from paymentMethod string
          String displayCardNum = "**** **** **** 3947";
          String cardType = "Visa";
          if (paymentMethod.toLowerCase().contains("mastercard")) {
            cardType = "Mastercard";
          }
          final digitMatch = RegExp(r'\d+').firstMatch(paymentMethod);
          if (digitMatch != null) {
            displayCardNum = "**** **** **** ${digitMatch.group(0)}";
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Order meta and status header card
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order №$orderNum",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Tracking number: ",
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            Text(
                              "IW${orderId.replaceAll('-', '').substring(0, 10).toUpperCase()}",
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black),
                            ),
                          ],
                        ),
                        Text(
                          status == "DELIVERED"
                              ? "Delivered"
                              : (status == "PROCESSING" ? "Processing" : "Cancelled"),
                          style: TextStyle(
                            color: status == "DELIVERED"
                                ? Colors.green
                                : (status == "PROCESSING" ? Colors.orange : Colors.red),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Items Header
              Text(
                "${items.length} items",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
              ),
              const SizedBox(height: 14),

              // Items List
              ...items.map((item) {
                final name = item["productName"] ?? "";
                final img = item["productImageUrl"] ?? "";
                final price = item["price"] as double;
                final qty = item["quantity"] as int;
                final size = item["size"] ?? "M";
                final color = item["color"] ?? "Black";

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                        child: SizedBox(
                          width: 80,
                          height: 104,
                          child: img.startsWith("assets")
                              ? Image.asset(img, fit: BoxFit.cover)
                              : Image.network(
                                  img,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: Colors.grey[100]),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Product Details
                      Expanded(
                        child: Container(
                          height: 104,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        "Mango",
                                        style: TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text("Color: ", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      Text(color, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500)),
                                      const SizedBox(width: 16),
                                      const Text("Size: ", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      Text(size, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500)),
                                      const SizedBox(width: 16),
                                      const Text("Units: ", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      Text("$qty", style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    _formatPrice(price * qty),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),
              
              // Order Information Section Title
              const Text(
                "Order information",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
              ),
              const SizedBox(height: 18),

              // Shipping Address Row
              _buildInfoRowText("Shipping Address", shippingAddress),

              // Payment Method Row
              _buildInfoRow(
                "Payment method",
                Row(
                  children: [
                    _buildCardLogo(cardType),
                    const SizedBox(width: 12),
                    Text(
                      displayCardNum,
                      style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              // Delivery Method Row
              _buildInfoRowText("Delivery method", "$shippingMethod, 3 days, 15\$"),

              // Discount Row
              _buildInfoRowText("Discount", discount > 0 ? "${_formatPrice(discount)} off, Personal promo code" : "0đ"),

              // Total Amount Row
              _buildInfoRowText("Total Amount", _formatPrice(total)),

              const SizedBox(height: 32),

              // Bottom Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Reorder",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Leave feedback",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
