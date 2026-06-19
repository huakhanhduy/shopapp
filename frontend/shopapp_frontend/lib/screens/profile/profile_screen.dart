import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../login/login_screen.dart';
import '../cart/address_management_screen.dart';
import '../cart/payment_methods_screen.dart';
import '../../services/promo_service.dart';
import '../../services/order_service.dart';
import '../../services/address_service.dart';
import '../../services/payment_service.dart';
import 'my_orders_screen.dart';
import 'settings_screen.dart';
import 'my_reviews_screen.dart';
import '../../services/review_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _orderCount = 0;
  int _addressCount = 0;
  int _reviewCount = 0;
  String _paymentCardText = "No cards added";
  String? _avatarBase64;

  @override
  void initState() {
    super.initState();
    _loadDynamicCounts();
  }

  void _loadDynamicCounts() async {
    try {
      final orders = await OrderService().getOrders();
      final addresses = await AddressService().getAddresses();
      final cards = await PaymentService().getCards();
      final reviews = await ReviewService().getMyReviews();

      String cardText = "No cards added";
      if (cards.isNotEmpty) {
        final def = cards.firstWhere((c) => c["isDefault"] == true, orElse: () => cards.first);
        final rawNum = def["cardNumber"] ?? "";
        final brand = def["cardType"] ?? "Card";
        if (rawNum.length > 4) {
          cardText = "$brand **${rawNum.substring(rawNum.length - 4)}";
        } else {
          cardText = "$brand **$rawNum";
        }
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String? base64Str;
      if (authProvider.isAuthenticated && authProvider.userProfile != null) {
        final email = authProvider.userProfile!["email"] ?? "";
        final prefs = await SharedPreferences.getInstance();
        base64Str = prefs.getString("avatar_$email");
      }

      if (mounted) {
        setState(() {
          _orderCount = orders.length;
          _addressCount = addresses.length;
          _paymentCardText = cardText;
          _avatarBase64 = base64Str;
          _reviewCount = reviews.length;
        });
      }
    } catch (_) {}
  }

  void _changeAvatar() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profile = authProvider.userProfile;
    if (profile == null) return;
    final email = profile["email"] ?? "";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Đổi ảnh đại diện",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color(0xffDB3022)),
                title: const Text("Chụp ảnh mới", style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, email);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xffDB3022)),
                title: const Text("Chọn từ thư viện", style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, email);
                },
              ),
              if (_avatarBase64 != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text("Xóa ảnh hiện tại", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                  onTap: () async {
                    Navigator.pop(context);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove("avatar_$email");
                    setState(() {
                      _avatarBase64 = null;
                    });
                  },
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _pickImage(ImageSource source, String email) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("avatar_$email", base64Image);
        setState(() {
          _avatarBase64 = base64Image;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cập nhật ảnh đại diện thành công")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi chọn ảnh: $e")),
        );
      }
    }
  }

  void _showPromocodes(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text("Available Promocodes", style: TextStyle(fontWeight: FontWeight.bold)),
          content: FutureBuilder<List<Map<String, dynamic>>>(
            future: PromoService().getPromoCodes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xffDB3022)))),
                );
              }
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }

              final promos = snapshot.data ?? [];
              if (promos.isEmpty) {
                return const Text("No promocodes available currently.");
              }

              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: promos.length,
                  itemBuilder: (context, index) {
                    final p = promos[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(p["code"], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Discount of ${p["discountPercent"]}% off"),
                      trailing: const Icon(Icons.local_offer, color: Color(0xffDB3022)),
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.black)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profile = authProvider.userProfile;
    const primaryColor = Color(0xffDB3022);

    if (!authProvider.isAuthenticated || profile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("You are not logged in"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Log In"),
              )
            ],
          ),
        ),
      );
    }

    final String fullName = "${profile["lastName"] ?? ""} ${profile["firstName"] ?? ""}".trim();
    final String email = profile["email"] ?? "";

    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Giant header title
          const Text(
            "My profile",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),

          // User Info section
          Row(
            children: [
              GestureDetector(
                onTap: _changeAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: _avatarBase64 != null
                          ? MemoryImage(base64Decode(_avatarBase64!))
                          : const AssetImage("assets/images/avata1.png") as ImageProvider,
                      backgroundColor: Colors.grey[200],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xffDB3022),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Menu list items separated by divider lines
          _buildMenuTile(
            title: "My orders",
            subtitle: _orderCount == 1 ? "Already have 1 order" : "Already have $_orderCount orders",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
              ).then((_) => _loadDynamicCounts());
            },
          ),
          const Divider(height: 1, color: Color(0xffEEEEEE)),
          
          _buildMenuTile(
            title: "Shipping addresses",
            subtitle: _addressCount == 1 ? "1 address" : "$_addressCount addresses",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressManagementScreen()),
              ).then((_) => _loadDynamicCounts());
            },
          ),
          const Divider(height: 1, color: Color(0xffEEEEEE)),
          
          _buildMenuTile(
            title: "Payment methods",
            subtitle: _paymentCardText,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
              ).then((_) => _loadDynamicCounts());
            },
          ),
          const Divider(height: 1, color: Color(0xffEEEEEE)),
          
          _buildMenuTile(
            title: "Promocodes",
            subtitle: "You have special promocodes",
            onTap: () => _showPromocodes(context),
          ),
          const Divider(height: 1, color: Color(0xffEEEEEE)),
          
          _buildMenuTile(
            title: "My reviews",
            subtitle: _reviewCount == 1 ? "Already have 1 review" : "Already have $_reviewCount reviews",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyReviewsScreen()),
              ).then((_) => _loadDynamicCounts());
            },
          ),
          const Divider(height: 1, color: Color(0xffEEEEEE)),
          
          _buildMenuTile(
            title: "Settings",
            subtitle: "Notifications, password",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ).then((_) => _loadDynamicCounts());
            },
          ),
          const Divider(height: 1, color: Color(0xffEEEEEE)),

          const SizedBox(height: 36),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () async {
                Provider.of<CartProvider>(context, listen: false).clearLocalData();
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                "LOG OUT",
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}