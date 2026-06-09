import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/address_service.dart';

class AddressManagementScreen extends StatefulWidget {
  final bool selectMode; // If true, tapping an address selects it and pops

  const AddressManagementScreen({
    super.key,
    this.selectMode = false,
  });

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  final _addressService = AddressService();
  List<Map<String, dynamic>> _addresses = [];
  bool _loading = false;
  bool _showAddForm = false;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isDefaultAddress = false;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _fetchAddresses() async {
    setState(() {
      _loading = true;
    });
    try {
      final data = await _addressService.getAddresses();
      setState(() {
        _addresses = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải địa chỉ: $e")),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    final request = {
      "fullName": _nameController.text.trim(),
      "phoneNumber": _phoneController.text.trim(),
      "streetAddress": _streetController.text.trim(),
      "city": _cityController.text.trim(),
      "state": _stateController.text.trim(),
      "zipCode": _zipController.text.trim(),
      "country": _countryController.text.trim(),
      "isDefault": _isDefaultAddress,
    };

    try {
      await _addressService.createAddress(request);
      setState(() {
        _showAddForm = false;
        // Reset form
        _nameController.clear();
        _phoneController.clear();
        _streetController.clear();
        _cityController.clear();
        _stateController.clear();
        _zipController.clear();
        _countryController.clear();
        _isDefaultAddress = false;
      });
      _fetchAddresses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi lưu địa chỉ: $e")),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  void _deleteAddress(String id) async {
    try {
      await _addressService.deleteAddress(id);
      _fetchAddresses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi xóa địa chỉ: $e")),
      );
    }
  }

  void _setDefault(String id) async {
    try {
      await _addressService.setDefaultAddress(id);
      _fetchAddresses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi cài đặt mặc định: $e")),
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
          _showAddForm ? "Adding Shipping Address" : "Địa chỉ nhận hàng",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _loading && _addresses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _showAddForm
              ? _buildAddAddressForm()
              : _buildAddressList(primaryColor),
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

  Widget _buildAddressList(Color primaryColor) {
    if (_addresses.isEmpty) {
      return const Center(child: Text("Bạn chưa có địa chỉ nhận hàng nào"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        final address = _addresses[index];
        final id = address["id"] as String;
        final name = address["fullName"] ?? "";
        final phone = address["phoneNumber"] ?? "";
        final street = address["streetAddress"] ?? "";
        final city = address["city"] ?? "";
        final state = address["state"] ?? "";
        final country = address["country"] ?? "";
        final isDefault = address["isDefault"] == true;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          elevation: 2,
          child: InkWell(
            onTap: () {
              if (widget.selectMode) {
                Provider.of<CartProvider>(context, listen: false).selectAddress(address);
                Navigator.pop(context);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          if (isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "Mặc định",
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            )
                          else
                            TextButton(
                              onPressed: () => _setDefault(id),
                              child: const Text("Thiết lập mặc định", style: TextStyle(fontSize: 12)),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.grey),
                            onPressed: () => _deleteAddress(id),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("$street, $city, $state", style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(country, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text("SĐT: $phone", style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddAddressForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Họ và tên người nhận",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập tên người nhận" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Số điện thoại nhận hàng",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập số điện thoại" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _streetController,
              decoration: const InputDecoration(
                labelText: "Số nhà, tên đường (Street Address)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập số nhà, tên đường" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: "Thành phố / Tỉnh (City)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập thành phố" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stateController,
              decoration: const InputDecoration(
                labelText: "Quận / Huyện / Bang (State)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _zipController,
              decoration: const InputDecoration(
                labelText: "Mã Bưu điện (Zip Code)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: "Quốc gia (Country)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập quốc gia" : null,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text("Đặt làm địa chỉ nhận hàng mặc định"),
              value: _isDefaultAddress,
              onChanged: (val) {
                setState(() {
                  _isDefaultAddress = val ?? false;
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
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffDB3022),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("LƯU ĐỊA CHỈ"),
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
