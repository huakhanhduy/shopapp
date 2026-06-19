import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import 'order_details_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  final _orderService = OrderService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatPrice(double amount) {
    if (amount < 5000) {
      return "${amount.toInt()}\$";
    }
    // Format large numbers with dot separators, e.g. 150.000đ
    String value = amount.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String Function(Match) mathFunc = (Match match) => '${match[1]}.';
    return "${value.replaceAllMapped(reg, mathFunc)}đ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "My Orders",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Custom capsule TabBar
          Container(
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [
                Tab(text: "Delivered"),
                Tab(text: "Processing"),
                Tab(text: "Cancelled"),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tab Bar View content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList("DELIVERED"),
                _buildOrderList("PROCESSING"),
                _buildOrderList("CANCELLED"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(String status) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _orderService.getOrdersByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xffDB3022))));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Failed to load orders: ${snapshot.error}",
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return Center(
            child: Text(
              "No $status orders found.",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final orderId = order["id"] as String;
            final orderNum = order["orderNumber"] ?? "";
            final total = order["totalAmount"] as double;
            final dateStr = order["orderDate"] != null
                ? order["orderDate"].toString().substring(0, 10)
                : "";
            final qty = (order["items"] as List?)?.length ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Order number and Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order $orderNum",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 2: Tracking number
                  Row(
                    children: [
                      const Text(
                        "Tracking number: ",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      Text(
                        "IW${orderId.replaceAll('-', '').substring(0, 10).toUpperCase()}",
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 3: Quantity and Total Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Quantity: ",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          Text(
                            "$qty",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            "Total Amount: ",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          Text(
                            _formatPrice(total),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Row 4: Details button and Status text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailsScreen(orderId: orderId),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          child: const Text(
                            "Details",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                        ),
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
                      )
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
