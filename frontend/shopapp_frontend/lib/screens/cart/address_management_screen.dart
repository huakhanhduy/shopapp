import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/address_service.dart';

class AddressManagementScreen extends StatefulWidget {
  final bool selectMode;

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
  String? _editingAddressId;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load addresses: $e")),
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

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    final request = {
      "fullName": _nameController.text.trim(),
      "phoneNumber": "123456789", // Default dummy phone required by backend
      "streetAddress": _streetController.text.trim(),
      "city": _cityController.text.trim(),
      "state": _stateController.text.trim(),
      "zipCode": _zipController.text.trim(),
      "country": _countryController.text.trim(),
      "isDefault": _editingAddressId == null ? _addresses.isEmpty : false, // Default if first address
    };

    try {
      if (_editingAddressId != null) {
        await _addressService.updateAddress(_editingAddressId!, request);
      } else {
        await _addressService.createAddress(request);
      }
      setState(() {
        _showAddForm = false;
        _editingAddressId = null;
        _nameController.clear();
        _streetController.clear();
        _cityController.clear();
        _stateController.clear();
        _zipController.clear();
        _countryController.clear();
      });
      _fetchAddresses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save address: $e")),
        );
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _deleteAddress(String id) async {
    setState(() {
      _loading = true;
    });
    try {
      await _addressService.deleteAddress(id);
      _fetchAddresses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete address: $e")),
        );
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _setDefaultAndSelect(Map<String, dynamic> address) async {
    final id = address["id"] as String;
    setState(() {
      _loading = true;
    });
    try {
      await _addressService.setDefaultAddress(id);
      if (widget.selectMode && mounted) {
        Provider.of<CartProvider>(context, listen: false).selectAddress(address);
      }
      _fetchAddresses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to set address: $e")),
        );
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _startEdit(Map<String, dynamic> address) {
    setState(() {
      _editingAddressId = address["id"];
      _nameController.text = address["fullName"] ?? "";
      _streetController.text = address["streetAddress"] ?? "";
      _cityController.text = address["city"] ?? "";
      _stateController.text = address["state"] ?? "";
      _zipController.text = address["zipCode"] ?? "";
      _countryController.text = address["country"] ?? "";
      _showAddForm = true;
    });
  }

  void _startAdd() {
    setState(() {
      _editingAddressId = null;
      _nameController.clear();
      _streetController.clear();
      _cityController.clear();
      _stateController.clear();
      _zipController.clear();
      _countryController.clear();
      _showAddForm = true;
    });
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
          onPressed: () {
            if (_showAddForm) {
              setState(() {
                _showAddForm = false;
                _editingAddressId = null;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _showAddForm ? "Adding Shipping Address" : "Shipping Addresses",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _loading && _addresses.isEmpty
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xffDB3022))))
          : _showAddForm
              ? _buildAddingAddressForm()
              : _buildAddressList(),
      floatingActionButton: !_showAddForm
          ? FloatingActionButton(
              onPressed: _startAdd,
              backgroundColor: Colors.black,
              shape: const CircleBorder(),
              elevation: 4,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
    );
  }

  Widget _buildAddressList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        if (_addresses.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                "No shipping addresses found. Tap + to add one.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ..._addresses.map((address) {
            final id = address["id"] as String;
            final name = address["fullName"] ?? "";
            final street = address["streetAddress"] ?? "";
            final city = address["city"] ?? "";
            final state = address["state"] ?? "";
            final zip = address["zipCode"] ?? "";
            final country = address["country"] ?? "";
            final isDefault = address["isDefault"] == true;

            return Container(
              margin: const EdgeInsets.only(bottom: 24),
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
                ],
              ),
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
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _startEdit(address),
                        child: const Text(
                          "Edit",
                          style: TextStyle(
                            color: Color(0xffDB3022),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    street,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$city, $state $zip, $country",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _setDefaultAndSelect(address);
                          if (widget.selectMode) {
                            // Already popped in _setDefaultAndSelect or we can pop here directly
                            Navigator.pop(context);
                          }
                        },
                        child: Row(
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
                                    _setDefaultAndSelect(address);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Use as the shipping address",
                              style: TextStyle(fontSize: 13, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                        onPressed: () => _deleteAddress(id),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAddingAddressForm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 48,
            ),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name field
                    _buildFormInput(
                      controller: _nameController,
                      label: "Full name",
                      validator: (val) => val == null || val.isEmpty ? "Full name is required" : null,
                    ),
                    const SizedBox(height: 20),

                    // Address field
                    _buildFormInput(
                      controller: _streetController,
                      label: "Address",
                      validator: (val) => val == null || val.isEmpty ? "Address is required" : null,
                    ),
                    const SizedBox(height: 20),

                    // City field
                    _buildFormInput(
                      controller: _cityController,
                      label: "City",
                      validator: (val) => val == null || val.isEmpty ? "City is required" : null,
                    ),
                    const SizedBox(height: 20),

                    // State/Province/Region field
                    _buildFormInput(
                      controller: _stateController,
                      label: "State/Province/Region",
                    ),
                    const SizedBox(height: 20),

                    // Zip Code field
                    _buildFormInput(
                      controller: _zipController,
                      label: "Zip Code (Postal Code)",
                    ),
                    const SizedBox(height: 20),

                    // Country field
                    _buildFormInput(
                      controller: _countryController,
                      label: "Country",
                      validator: (val) => val == null || val.isEmpty ? "Country is required" : null,
                      suffixIcon: const Icon(Icons.chevron_right, color: Colors.grey),
                    ),
                    const Spacer(),
                    const SizedBox(height: 40),

                    // SAVE ADDRESS Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saveAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffDB3022),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          "SAVE ADDRESS",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormInput({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
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
        controller: controller,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }
}
