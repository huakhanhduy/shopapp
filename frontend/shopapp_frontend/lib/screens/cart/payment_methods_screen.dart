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
  bool _showAddForm = false;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _holderController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  String _selectedCardType = "Visa";
  bool _isDefaultCard = false;

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  @override
  void dispose() {
    _holderController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    super.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải danh sách thẻ: $e")),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    final request = {
      "cardHolderName": _holderController.text.toUpperCase().trim(),
      "cardNumber": _numberController.text.trim(),
      "expiryDate": _expiryController.text.trim(),
      "cardType": _selectedCardType,
      "isDefault": _isDefaultCard,
    };

    try {
      await _paymentService.createCard(request);
      setState(() {
        _showAddForm = false;
        _holderController.clear();
        _numberController.clear();
        _expiryController.clear();
        _isDefaultCard = false;
      });
      _fetchCards();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi lưu thẻ: $e")),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  void _deleteCard(String id) async {
    try {
      await _paymentService.deleteCard(id);
      _fetchCards();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi xóa thẻ: $e")),
      );
    }
  }

  void _setDefault(String id) async {
    try {
      await _paymentService.setDefaultCard(id);
      _fetchCards();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi thiết lập thẻ mặc định: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xffDB3022);

    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _showAddForm ? "Add new card" : "Phương thức thanh toán",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _loading && _cards.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _showAddForm
              ? _buildAddCardForm(primaryColor)
              : _buildCardList(primaryColor),
      floatingActionButton: !_showAddForm
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showAddForm = true;
                });
              },
              backgroundColor: Colors.black,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildCardList(Color primaryColor) {
    if (_cards.isEmpty) {
      return const Center(child: Text("Bạn chưa thêm thẻ thanh toán nào"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        final card = _cards[index];
        final id = card["id"] as String;
        final holder = card["cardHolderName"] ?? "";
        final rawNumber = card["cardNumber"] ?? "";
        final expiry = card["expiryDate"] ?? "";
        final type = card["cardType"] ?? "Visa";
        final isDefault = card["isDefault"] == true;

        // Mask card number for display (e.g. **** **** **** 4321)
        String displayNum = rawNumber;
        if (rawNumber.length > 4) {
          displayNum = "**** **** **** ${rawNumber.substring(rawNumber.length - 4)}";
        }

        // ATM Card design gradients
        final List<Color> cardGradient = index % 2 == 0
            ? [const Color(0xff292e49), const Color(0xff536976)] // Dark Slate
            : [const Color(0xff8a2387), const Color(0xffe94057), const Color(0xfff27121)]; // Sunset gradient

        return Column(
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
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
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
                        // Card Chip Icon Mock
                        Container(
                          width: 44,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xffFFD700).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.grid_3x3, color: Colors.black38),
                        ),
                        Text(
                          type.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      displayNum,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 2,
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
                              "CHỦ THẺ",
                              style: TextStyle(color: Colors.white60, fontSize: 10),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              holder,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "HẠN DÙNG",
                              style: TextStyle(color: Colors.white60, fontSize: 10),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              expiry,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isDefault,
                      onChanged: (val) {
                        if (val == true) _setDefault(id);
                      },
                    ),
                    const Text("Sử dụng làm thẻ mặc định", style: TextStyle(fontSize: 13)),
                  ],
                ),
                TextButton(
                  onPressed: () => _deleteCard(id),
                  child: const Text("Xóa thẻ", style: TextStyle(color: Colors.red)),
                )
              ],
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildAddCardForm(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Holder Name
            TextFormField(
              controller: _holderController,
              decoration: const InputDecoration(
                labelText: "Tên trên thẻ (CARDHOLDER NAME)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập tên chủ thẻ" : null,
            ),
            const SizedBox(height: 12),
            // Card Number
            TextFormField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Số thẻ (CARD NUMBER)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              validator: (val) => val != null && val.length >= 12 ? null : "Số thẻ không hợp lệ",
            ),
            const SizedBox(height: 12),
            // Expiry
            TextFormField(
              controller: _expiryController,
              decoration: const InputDecoration(
                labelText: "Ngày hết hạn (EXPIRY DATE)",
                hintText: "MM/YY",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              validator: (val) => val != null && val.contains("/") ? null : "MM/YY không hợp lệ",
            ),
            const SizedBox(height: 12),
            // Type dropdown
            DropdownButtonFormField<String>(
              value: _selectedCardType,
              decoration: const InputDecoration(
                labelText: "Loại thẻ (CARD TYPE)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "Visa", child: Text("Visa")),
                DropdownMenuItem(value: "Mastercard", child: Text("Mastercard")),
                DropdownMenuItem(value: "JCB", child: Text("JCB")),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCardType = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text("Đặt làm thẻ thanh toán mặc định"),
              value: _isDefaultCard,
              onChanged: (val) {
                setState(() {
                  _isDefaultCard = val ?? false;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showAddForm = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("HỦY"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("THÊM THẺ"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
