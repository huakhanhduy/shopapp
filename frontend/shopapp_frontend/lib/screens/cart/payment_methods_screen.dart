import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/payment_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final bool selectMode;

  const PaymentMethodsScreen({
    super.key,
    this.selectMode = false,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _paymentService = PaymentService();
  List<Map<String, dynamic>> _cards = [];
  bool _loading = false;

  // Controllers for Add Card Bottom Sheet
  final _formKey = GlobalKey<FormState>();
  final _holderController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  String _detectedCardType = "Visa";
  bool _isDefaultCard = false;

  @override
  void initState() {
    super.initState();
    _fetchCards();
    _numberController.addListener(_detectCardTypeFromNumber);
  }

  @override
  void dispose() {
    _holderController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _detectCardTypeFromNumber() {
    final text = _numberController.text.trim();
    if (text.startsWith('4')) {
      if (_detectedCardType != 'Visa') {
        setState(() {
          _detectedCardType = 'Visa';
        });
      }
    } else if (text.startsWith('5')) {
      if (_detectedCardType != 'Mastercard') {
        setState(() {
          _detectedCardType = 'Mastercard';
        });
      }
    } else if (text.startsWith('3')) {
      if (_detectedCardType != 'JCB') {
        setState(() {
          _detectedCardType = 'JCB';
        });
      }
    }
  }

  Future<void> _fetchCards() async {
    setState(() {
      _loading = true;
    });
    try {
      final data = await _paymentService.getCards();
      setState(() {
        _cards = data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load cards: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    // Local loading state while performing save
    Navigator.pop(context); // Close Bottom Sheet

    setState(() {
      _loading = true;
    });

    final request = {
      "cardHolderName": _holderController.text.toUpperCase().trim(),
      "cardNumber": _numberController.text.trim(),
      "expiryDate": _expiryController.text.trim(),
      "cardType": _detectedCardType,
      "isDefault": _isDefaultCard,
    };

    try {
      await _paymentService.createCard(request);
      _holderController.clear();
      _numberController.clear();
      _expiryController.clear();
      _cvvController.clear();
      _isDefaultCard = false;
      _detectCardTypeFromNumber();
      _fetchCards();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save card: $e")),
        );
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _deleteCard(String id) async {
    setState(() {
      _loading = true;
    });
    try {
      await _paymentService.deleteCard(id);
      _fetchCards();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete card: $e")),
        );
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _setDefault(String id) async {
    setState(() {
      _loading = true;
    });
    try {
      await _paymentService.setDefaultCard(id);
      _fetchCards();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to set default: $e")),
        );
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showAddCardBottomSheet() {
    _holderController.clear();
    _numberController.clear();
    _expiryController.clear();
    _cvvController.clear();
    _isDefaultCard = false;
    _detectedCardType = "Visa";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xffF9F9F9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Center(
                        child: Text(
                          "Add new card",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Name on Card Input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _holderController,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            labelText: "Name on card",
                            labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: InputBorder.none,
                          ),
                          validator: (val) => val == null || val.isEmpty ? "Name is required" : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card Number Input with Brand Logo
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _numberController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1),
                          decoration: InputDecoration(
                            labelText: "Card number",
                            labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: InputBorder.none,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: _buildCardLogoWidget(_detectedCardType),
                            ),
                          ),
                          onChanged: (value) {
                            // Trigger detect immediately in the bottom sheet context
                            String newType = "Visa";
                            if (value.startsWith('5')) {
                              newType = "Mastercard";
                            } else if (value.startsWith('3')) {
                              newType = "JCB";
                            }
                            if (newType != _detectedCardType) {
                              setModalState(() {
                                _detectedCardType = newType;
                              });
                            }
                          },
                          validator: (val) => val != null && val.trim().length >= 12 ? null : "Invalid card number",
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Expiry and CVV Side by Side
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _expiryController,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                decoration: const InputDecoration(
                                  labelText: "Expiry Date",
                                  hintText: "MM/YY",
                                  labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  border: InputBorder.none,
                                ),
                                validator: (val) => val != null && val.contains('/') ? null : "Use MM/YY",
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _cvvController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                decoration: const InputDecoration(
                                  labelText: "CVV",
                                  labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  border: InputBorder.none,
                                  suffixIcon: Icon(Icons.help_outline, color: Colors.grey, size: 20),
                                ),
                                validator: (val) => val != null && val.trim().length >= 3 ? null : "Required",
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Set as default checkbox
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _isDefaultCard,
                              activeColor: Colors.black,
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) {
                                setModalState(() {
                                  _isDefaultCard = val ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Set as default payment method",
                            style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ADD CARD Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _saveCard,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffDB3022),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            "ADD CARD",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCardLogoWidget(String type) {
    final lower = type.toLowerCase();
    if (lower == "mastercard") {
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
    } else if (lower == "visa") {
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
      return const Text(
        "JCB",
        style: TextStyle(
          color: Colors.blueAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Payment methods",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _loading && _cards.isEmpty
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xffDB3022))))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                const Text(
                  "Your payment cards",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 18),
                if (_cards.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        "No payment cards found. Tap + to add one.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ..._cards.asMap().entries.map((entry) {
                    final index = entry.key;
                    final card = entry.value;
                    final id = card["id"] as String;
                    final holder = card["cardHolderName"] ?? "";
                    final rawNumber = card["cardNumber"] ?? "";
                    final expiry = card["expiryDate"] ?? "";
                    final type = card["cardType"] ?? "Visa";
                    final isDefault = card["isDefault"] == true;

                    String displayNum = rawNumber;
                    if (rawNumber.length > 4) {
                      displayNum = "**** **** **** ${rawNumber.substring(rawNumber.length - 4)}";
                    }

                    // Card visual styling based on index (Mockup 2 features dark slate card first, grey card second)
                    final List<Color> cardGradient = index % 2 == 0
                        ? [const Color(0xff222222), const Color(0xff2d2d2d)] // Dark Slate/Black
                        : [const Color(0xff9E9E9E), const Color(0xff757575)]; // Grey

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (widget.selectMode) {
                                Provider.of<CartProvider>(context, listen: false).selectPaymentCard(card);
                                Navigator.pop(context);
                              }
                            },
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: cardGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Card Chip
                                      Container(
                                        width: 42,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffFFD700).withOpacity(0.85),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Icon(Icons.grid_3x3, color: Colors.black45, size: 20),
                                      ),
                                      // Brand logo with customized colors
                                      Text(
                                        type.toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: type.toLowerCase() == "visa" ? 20 : 16,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: type.toLowerCase() == "visa" ? FontStyle.italic : FontStyle.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    displayNum,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      letterSpacing: 2.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Card Holder Name",
                                            style: TextStyle(color: Colors.white60, fontSize: 9),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            holder,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Expiry Date",
                                            style: TextStyle(color: Colors.white60, fontSize: 9),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            expiry,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: isDefault,
                                      activeColor: Colors.black,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      onChanged: (val) {
                                        if (val == true) {
                                          _setDefault(id);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Use as default payment method",
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black),
                                  ),
                                ],
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                onPressed: () => _deleteCard(id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCardBottomSheet,
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
