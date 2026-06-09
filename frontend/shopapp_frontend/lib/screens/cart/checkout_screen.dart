import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/address_service.dart';
import '../../services/payment_service.dart';
import '../../services/order_service.dart';
import 'address_management_screen.dart';
import 'payment_methods_screen.dart';
import 'success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressService = AddressService();
  final _paymentService = PaymentService();
  final _orderService = OrderService();
  bool _submitting = false;

  final Map<String, double> _shippingFees = {
    "FedEx": 30000,
    "USPS": 15000,
    "DHL": 50000,
  };

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  void _loadDefaults() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    // Load default address if none is selected
    if (cartProvider.selectedAddress == null) {
      try {
        final addresses = await _addressService.getAddresses();
        if (addresses.isNotEmpty) {
          final def = addresses.firstWhere((a) => a["isDefault"] == true, orElse: () => addresses.first);
          cartProvider.selectAddress(def);
        }
      } catch (_) {}
    }

    // Load default card if none is selected
    if (cartProvider.selectedPaymentCard == null) {
      try {
        final cards = await _paymentService.getCards();
        if (cards.isNotEmpty) {
          final def = cards.firstWhere((c) => c["isDefault"] == true, orElse: () => cards.first);
          cartProvider.selectPaymentCard(def);
        }
      } catch (_) {}
    }
  }

  void _submitOrder() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (cartProvider.selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn địa chỉ giao hàng")),
      );
      return;
    }

    if (cartProvider.selectedPaymentCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn phương thức thanh toán")),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    final addr = cartProvider.selectedAddress!;
    final card = cartProvider.selectedPaymentCard!;

    final addressStr = "${addr["fullName"]}, SĐT: ${addr["phoneNumber"]}, ${addr["streetAddress"]}, ${addr["city"]}, ${addr["state"]}, ${addr["country"]}";
    final paymentStr = "${card["cardType"]} (${card["cardNumber"].toString().substring(card["cardNumber"].toString().length - 4)})";

    final itemsRequest = cartProvider.items.map((item) {
      double price = item.product.discountPrice > 0 ? item.product.discountPrice : item.product.regularPrice;
      return {
        "productId": item.product.id,
        "size": item.size,
        "color": item.color,
        "price": price,
        "quantity": item.quantity,
      };
    }).toList();

    final request = {
      "items": itemsRequest,
      "promoCode": cartProvider.appliedPromoCode,
      "shippingAddress": addressStr,
      "shippingMethod": cartProvider.selectedShippingMethod,
      "paymentMethod": paymentStr,
      "subtotal": cartProvider.subtotal,
      "deliveryFee": _shippingFees[cartProvider.selectedShippingMethod] ?? 30000,
      "discountAmount": cartProvider.discountAmount,
      "totalAmount": cartProvider.subtotal + (_shippingFees[cartProvider.selectedShippingMethod] ?? 30000) - cartProvider.discountAmount,
    };

    try {
      await _orderService.placeOrder(request);
      cartProvider.clearCart();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuccessScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi đặt hàng: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    const primaryColor = Color(0xffDB3022);

    double shipFee = _shippingFees[cartProvider.selectedShippingMethod] ?? 30000;
    double orderTotal = cartProvider.subtotal + shipFee - cartProvider.discountAmount;

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
          "Thanh toán",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _submitting
          ? const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)),
                SizedBox(height: 16),
                Text("Đang xử lý thanh toán...", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Shipping Address Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Địa chỉ giao hàng",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddressManagementScreen(selectMode: true)),
                        );
                      },
                      child: const Text("Thay đổi", style: TextStyle(color: primaryColor)),
                    ),
                  ],
                ),
                // Shipping Address Card
                _buildAddressCard(cartProvider.selectedAddress),
                const SizedBox(height: 24),

                // Payment Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Phương thức thanh toán",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PaymentMethodsScreen(selectMode: true)),
                        );
                      },
                      child: const Text("Thay đổi", style: TextStyle(color: primaryColor)),
                    ),
                  ],
                ),
                // Payment Card
                _buildPaymentCard(cartProvider.selectedPaymentCard),
                const SizedBox(height: 24),

                // Shipping Method Header
                const Text(
                  "Phương thức vận chuyển",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildShippingMethods(cartProvider),
                const SizedBox(height: 32),

                // Cost summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Đơn hàng", style: TextStyle(color: Colors.black54)),
                          Text("${cartProvider.subtotal.toInt()}đ", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Vận chuyển", style: TextStyle(color: Colors.black54)),
                          Text("${shipFee.toInt()}đ", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (cartProvider.discountPercent > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Giảm giá", style: TextStyle(color: Colors.red)),
                            Text("-${cartProvider.discountAmount.toInt()}đ", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tổng cộng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            "${orderTotal.toInt()}đ",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Submit order button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text("XÁC NHẬN ĐƠN HÀNG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic>? address) {
    if (address == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text("Chưa chọn địa chỉ giao hàng. Nhấn Thay đổi để thêm/chọn."),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address["fullName"] ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            "${address["streetAddress"]}, ${address["city"]}, ${address["state"]}",
            style: const TextStyle(color: Colors.black87),
          ),
          Text(address["country"] ?? ""),
          const SizedBox(height: 6),
          Text("SĐT: ${address["phoneNumber"]}", style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic>? card) {
    if (card == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text("Chưa chọn phương thức thanh toán. Nhấn Thay đổi để thêm/chọn."),
      );
    }

    final rawNum = card["cardNumber"] ?? "";
    String displayNum = rawNum;
    if (rawNum.length > 4) {
      displayNum = "**** **** **** ${rawNum.substring(rawNum.length - 4)}";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              card["cardType"].toString().toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayNum,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  card["cardHolderName"] ?? "",
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildShippingMethods(CartProvider cartProvider) {
    final methods = ["FedEx", "USPS", "DHL"];
    final deliveryTimes = {
      "FedEx": "2-3 ngày làm việc",
      "USPS": "4-6 ngày làm việc",
      "DHL": "1 ngày (Hỏa tốc)",
    };

    return Row(
      children: methods.map((method) {
        final isSelected = cartProvider.selectedShippingMethod == method;
        double fee = _shippingFees[method] ?? 30000;

        return Expanded(
          child: GestureDetector(
            onTap: () => cartProvider.selectShippingMethod(method),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xffDB3022) : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    method,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${fee.toInt()}đ",
                    style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    deliveryTimes[method]!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
