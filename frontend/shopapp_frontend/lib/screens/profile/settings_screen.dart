import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Notification switches
  bool _salesNotif = true;
  bool _newArrivalsNotif = false;
  bool _deliveryStatusNotif = true;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).userProfile;
    if (user != null) {
      _firstNameController.text = user["firstName"] ?? "";
      _lastNameController.text = user["lastName"] ?? "";
      _phoneController.text = user["phoneNumber"] ?? "";
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    try {
      await Provider.of<AuthProvider>(context, listen: false).updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thông tin thành công")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi cập nhật: $e")),
      );
    }
  }

  void _showPasswordDialog() {
    final formKey = GlobalKey<FormState>();
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final repeatPasswordController = TextEditingController();
    bool loading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Thay đổi mật khẩu", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: oldPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: "Mật khẩu cũ"),
                        validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập mật khẩu cũ" : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: "Mật khẩu mới"),
                        validator: (val) => val != null && val.length >= 6 ? null : "Mật khẩu tối thiểu 6 ký tự",
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: repeatPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: "Nhập lại mật khẩu mới"),
                        validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập lại mật khẩu mới" : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          if (newPasswordController.text != repeatPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Mật khẩu xác nhận không khớp")),
                            );
                            return;
                          }

                          setDialogState(() {
                            loading = true;
                          });

                          try {
                            await Provider.of<AuthProvider>(context, listen: false).changePassword(
                              oldPassword: oldPasswordController.text,
                              newPassword: newPasswordController.text,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Thay đổi mật khẩu thành công")),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
                              );
                            }
                          } finally {
                            setDialogState(() {
                              loading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffDB3022),
                    foregroundColor: Colors.white,
                  ),
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Thay đổi"),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xffDB3022);
    final authProvider = Provider.of<AuthProvider>(context);

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
          "Cài đặt tài khoản",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Personal Information Form
                Form(
                  key: _profileFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Thông tin cá nhân",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: "Họ",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập họ" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: "Tên",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập tên" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Số điện thoại",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập số điện thoại" : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("CẬP NHẬT THÔNG TIN", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 40),

                // Password Settings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Mật khẩu",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: _showPasswordDialog,
                      child: const Text("Thay đổi mật khẩu", style: TextStyle(color: primaryColor)),
                    ),
                  ],
                ),
                
                const Divider(height: 40),

                // Notification Settings
                const Text(
                  "Thông báo",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text("Khuyến mãi & Giảm giá"),
                  subtitle: const Text("Nhận thông báo khi có chương trình sale"),
                  value: _salesNotif,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    setState(() {
                      _salesNotif = val;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text("Bộ sưu tập mới"),
                  subtitle: const Text("Nhận thông báo khi có hàng mới về"),
                  value: _newArrivalsNotif,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    setState(() {
                      _newArrivalsNotif = val;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text("Trạng thái đơn hàng"),
                  subtitle: const Text("Nhận thông báo khi đơn hàng thay đổi trạng thái"),
                  value: _deliveryStatusNotif,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    setState(() {
                      _deliveryStatusNotif = val;
                    });
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }
}
