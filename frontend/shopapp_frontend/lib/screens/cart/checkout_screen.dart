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
    "FedEx": 15000,
    "USPS": 10000,
    "DHL": 20000,
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
        const SnackBar(content: Text("Please select a shipping address")),
      );
      return;
    }

    if (cartProvider.selectedPaymentCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a payment method")),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    final addr = cartProvider.selectedAddress!;
    final card = cartProvider.selectedPaymentCard!;

    final addressStr = "${addr["fullName"]}, Phone: ${addr["phoneNumber"]}, ${addr["streetAddress"]}, ${addr["city"]}, ${addr["state"]}, ${addr["country"]}";
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
      "deliveryFee": _shippingFees[cartProvider.selectedShippingMethod] ?? 15000,
      "discountAmount": cartProvider.discountAmount,
      "totalAmount": cartProvider.subtotal + (_shippingFees[cartProvider.selectedShippingMethod] ?? 15000) - cartProvider.discountAmount,
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
          SnackBar(content: Text("Order failed: $e")),
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

  Widget _buildCardLogo(String? cardType) {
    final type = cardType?.toLowerCase() ?? "";
    if (type == "mastercard") {
      return SizedBox(
        width: 32,
        height: 20,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xffEB001B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 12,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xffF79E1B).withOpacity(0.85),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (type == "visa") {
      return const Text(
        "VISA",
        style: TextStyle(
          color: Color(0xff1A1F71),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      );
    } else {
      return const Icon(Icons.credit_card, color: Colors.grey);
    }
  }

  Widget _buildDeliveryLogo(String method) {
    if (method == "FedEx") {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Fed",
            style: TextStyle(
              color: Color(0xff4D148C),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            "Ex",
            style: TextStyle(
              color: Color(0xffFF6200),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      );
    } else if (method == "USPS") {
      return const Text(
        "USPS",
        style: TextStyle(
          color: Color(0xff003366),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      );
    } else if (method == "DHL") {
      return const Text(
        "DHL",
        style: TextStyle(
          color: Color(0xffD00000),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          letterSpacing: -1,
        ),
      );
    }
    return Text(
      method,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    const primaryColor = Color(0xffDB3022);

    double shipFee = _shippingFees[cartProvider.selectedShippingMethod] ?? 15000;
    double orderTotal = cartProvider.subtotal + shipFee - cartProvider.discountAmount;

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
          "Checkout",
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
                Text("Processing order...", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                // Shipping Address Section
                const Text(
                  "Shipping address",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildAddressCard(cartProvider.selectedAddress),
                const SizedBox(height: 28),

                // Payment Section
                const Text(
                  "Payment",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildPaymentCard(cartProvider.selectedPaymentCard),
                const SizedBox(height: 28),

                // Delivery Method Section
                const Text(
                  "Delivery method",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildShippingMethods(cartProvider),
                const SizedBox(height: 40),

                // Cost Summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Order:",
                            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "${cartProvider.subtotal.toInt()}đ",
                            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Delivery:",
                            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "${shipFee.toInt()}đ",
                            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (cartProvider.discountAmount > 0) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Discount:",
                              style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "-${cartProvider.discountAmount.toInt()}đ",
                              style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Summary:",
                            style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${orderTotal.toInt()}đ",
                            style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Submit order button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text("SUBMIT ORDER", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic>? address) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: address == null
                ? const Text(
                    "Please select or add a shipping address",
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address["fullName"] ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        address["streetAddress"] ?? "",
                        style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${address["city"] ?? ""}, ${address["state"] ?? ""} ${address["zipCode"] ?? ""}, ${address["country"] ?? ""}",
                        style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.3),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressManagementScreen(selectMode: true)),
              ).then((_) => setState(() {}));
            },
            child: const Text(
              "Change",
              style: TextStyle(
                color: Color(0xffDB3022),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic>? card) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        children: [
          Expanded(
            child: card == null
                ? const Text(
                    "Please select or add a payment method",
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  )
                : Row(
                    children: [
                      _buildCardLogo(card["cardType"]),
                      const SizedBox(width: 16),
                      Text(
                        card["cardNumber"] != null && card["cardNumber"].toString().length > 4
                            ? "**** **** **** ${card["cardNumber"].toString().substring(card["cardNumber"].toString().length - 4)}"
                            : "**** **** **** 3947",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentMethodsScreen(selectMode: true)),
              ).then((_) => setState(() {}));
            },
            child: const Text(
              "Change",
              style: TextStyle(
                color: Color(0xffDB3022),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingMethods(CartProvider cartProvider) {
    final methods = ["FedEx", "USPS", "DHL"];
    final deliveryTimes = {
      "FedEx": "2-3 days",
      "USPS": "2-3 days",
      "DHL": "2-3 days",
    };

    return Row(
      children: methods.map((method) {
        final isSelected = cartProvider.selectedShippingMethod == method;
        return Expanded(
          child: GestureDetector(
            onTap: () => cartProvider.selectShippingMethod(method),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? const Color(0xffDB3022) : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDeliveryLogo(method),
                  const SizedBox(height: 6),
                  Text(
                    deliveryTimes[method]!,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
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
