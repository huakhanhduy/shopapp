import 'package:flutter/material.dart';
import '../../services/order_service.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chi tiết đơn hàng",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: orderService.getOrderById(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Lỗi tải chi tiết đơn hàng: ${snapshot.error}"),
            );
          }

          final order = snapshot.data!;
          final orderNum = order["orderNumber"] ?? "";
          final status = order["status"] ?? "PROCESSING";
          final total = order["totalAmount"] as double;
          final subtotal = order["subtotal"] as double;
          final shipping = order["deliveryFee"] as double;
          final discount = order["discountAmount"] as double;
          final shippingAddress = order["shippingAddress"] ?? "";
          final paymentMethod = order["paymentMethod"] ?? "";
          final items = order["items"] as List? ?? [];
          final dateStr = order["orderDate"] != null
              ? order["orderDate"].toString().substring(0, 10)
              : "";

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Order metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    orderNum,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    dateStr,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    status == "PROCESSING"
                        ? "Đang chuẩn bị"
                        : (status == "DELIVERED" ? "Giao hàng thành công" : "Đã hủy"),
                    style: TextStyle(
                      color: status == "PROCESSING"
                          ? Colors.orange
                          : (status == "DELIVERED" ? Colors.green : Colors.red),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "${items.length} sản phẩm",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Items Header
              const Text(
                "Sản phẩm đã mua",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              
              // Items List
              ...items.map((item) {
                final name = item["productName"] ?? "";
                final img = item["productImageUrl"] ?? "";
                final price = item["price"] as double;
                final qty = item["quantity"] as int;
                final size = item["size"] ?? "M";
                final color = item["color"] ?? "Black";

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 60,
                          height: 70,
                          child: img.startsWith("assets")
                              ? Image.asset(img, fit: BoxFit.cover)
                              : Image.network(img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200])),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text("Màu: $color  Size: $size", style: const TextStyle(color: Colors.black54, fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Số lượng: $qty", style: const TextStyle(fontSize: 12)),
                                Text("${price.toInt()}đ", style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }),

              const Divider(height: 32),

              // Delivery details
              const Text(
                "Thông tin giao hàng",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(shippingAddress, style: const TextStyle(height: 1.4, color: Colors.black87)),

              const Divider(height: 32),

              // Payment details
              const Text(
                "Phương thức thanh toán",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(paymentMethod, style: const TextStyle(color: Colors.black87)),

              const Divider(height: 32),

              // Summary
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tạm tính", style: TextStyle(color: Colors.black54)),
                      Text("${subtotal.toInt()}đ", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Vận chuyển", style: TextStyle(color: Colors.black54)),
                      Text("${shipping.toInt()}đ", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (discount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Mã giảm giá", style: TextStyle(color: Colors.red)),
                        Text("-${discount.toInt()}đ", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tổng cộng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        "${total.toInt()}đ",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ],
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
