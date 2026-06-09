import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../login/login_screen.dart';
import '../cart/address_management_screen.dart';
import '../cart/payment_methods_screen.dart';
import '../../services/promo_service.dart';
import 'my_orders_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showPromocodes(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Mã giảm giá khả dụng", style: TextStyle(fontWeight: FontWeight.bold)),
          content: FutureBuilder<List<Map<String, dynamic>>>(
            future: PromoService().getPromoCodes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Text("Lỗi: ${snapshot.error}");
              }

              final promos = snapshot.data ?? [];
              if (promos.isEmpty) {
                return const Text("Không có mã giảm giá nào khả dụng");
              }

              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: promos.length,
                  itemBuilder: (context, index) {
                    final p = promos[index];
                    return ListTile(
                      title: Text(p["code"], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Giảm giá ${p["discountPercent"]}% tổng hóa đơn"),
                      trailing: const Icon(Icons.local_offer, color: Colors.red),
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Đóng"),
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
              const Text("Bạn chưa đăng nhập"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text("Đăng nhập"),
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Trang cá nhân",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User profile header
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: const AssetImage("assets/images/avata1.png"),
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Menu items
          _buildMenuTile(
            title: "Đơn hàng của tôi",
            subtitle: "Xem lịch sử mua hàng, trạng thái đơn hàng",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
              );
            },
          ),
          _buildMenuTile(
            title: "Địa chỉ nhận hàng",
            subtitle: "Quản lý địa chỉ giao hàng",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressManagementScreen()),
              );
            },
          ),
          _buildMenuTile(
            title: "Phương thức thanh toán",
            subtitle: "Quản lý thẻ ngân hàng, thẻ tín dụng",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
              );
            },
          ),
          _buildMenuTile(
            title: "Mã giảm giá (Promocodes)",
            subtitle: "Xem các chương trình khuyến mãi hiện có",
            onTap: () => _showPromocodes(context),
          ),
          _buildMenuTile(
            title: "Cài đặt tài khoản",
            subtitle: "Chỉnh sửa thông tin, đổi mật khẩu, thông báo",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () async {
                Provider.of<CartProvider>(context, listen: false).clearCart();
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout, color: primaryColor),
              label: const Text(
                "ĐĂNG XUẤT",
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}