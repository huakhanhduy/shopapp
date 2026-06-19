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
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController(text: "12/12/1989");

  // Notification switches
  bool _salesNotif = true;
  bool _newArrivalsNotif = false;
  bool _deliveryStatusNotif = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).userProfile;
    if (user != null) {
      final String lastName = user["lastName"] ?? "";
      final String firstName = user["firstName"] ?? "";
      _fullNameController.text = "$lastName $firstName".trim();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _updateProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    final String fullName = _fullNameController.text.trim();
    final nameParts = fullName.split(' ');
    final String firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final user = Provider.of<AuthProvider>(context, listen: false).userProfile;
    final String phone = user?["phoneNumber"] ?? "123456789";

    try {
      await Provider.of<AuthProvider>(context, listen: false).updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phone,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update failed: $e")),
        );
      }
    }
  }

  Widget _buildInputContainer({required Widget child}) {
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
      child: child,
    );
  }

  void _showPasswordBottomSheet() {
    final formKey = GlobalKey<FormState>();
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final repeatPasswordController = TextEditingController();
    bool modalLoading = false;

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
                  key: formKey,
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
                          "Password Change",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Old Password
                      _buildInputContainer(
                        child: TextFormField(
                          controller: oldPasswordController,
                          obscureText: true,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            labelText: "Old Password",
                            labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: InputBorder.none,
                          ),
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        ),
                      ),
                      
                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Password reset instructions sent to your email")),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // New Password
                      _buildInputContainer(
                        child: TextFormField(
                          controller: newPasswordController,
                          obscureText: true,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            labelText: "New Password",
                            labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: InputBorder.none,
                          ),
                          validator: (val) => val != null && val.length >= 6 ? null : "Min 6 characters",
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Repeat New Password
                      _buildInputContainer(
                        child: TextFormField(
                          controller: repeatPasswordController,
                          obscureText: true,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            labelText: "Repeat New Password",
                            labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: InputBorder.none,
                          ),
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // SAVE PASSWORD Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: modalLoading
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  if (newPasswordController.text != repeatPasswordController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Passwords do not match")),
                                    );
                                    return;
                                  }

                                  setModalState(() {
                                    modalLoading = true;
                                  });

                                  try {
                                    await Provider.of<AuthProvider>(context, listen: false).changePassword(
                                      oldPassword: oldPasswordController.text,
                                      newPassword: newPasswordController.text,
                                    );
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Password updated successfully")),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
                                    );
                                  } finally {
                                    setModalState(() {
                                      modalLoading = false;
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffDB3022),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: modalLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text(
                                  "SAVE PASSWORD",
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xffDB3022))))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Screen Title
                const Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Form section for Personal Information
                Form(
                  key: _profileFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Personal Information",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 14),

                      // Full name input box
                      _buildInputContainer(
                        child: TextFormField(
                          controller: _fullNameController,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            labelText: "Full name",
                            labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: InputBorder.none,
                          ),
                          validator: (val) => val == null || val.isEmpty ? "Full name is required" : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Date of Birth input box
                      _buildInputContainer(
                        child: TextFormField(
                          controller: _dobController,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            labelText: "Date of Birth",
                            labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // SAVE CHANGES Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Password change section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Password",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: _showPasswordBottomSheet,
                      child: const Text(
                        "Change",
                        style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                
                // Masked Password field
                _buildInputContainer(
                  child: TextFormField(
                    initialValue: "************",
                    readOnly: true,
                    obscureText: true,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
                    decoration: const InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Notifications Section
                const Text(
                  "Notifications",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 12),

                // Sales Switch
                _buildSwitchTile(
                  title: "Sales",
                  value: _salesNotif,
                  onChanged: (val) {
                    setState(() {
                      _salesNotif = val;
                    });
                  },
                ),
                
                // New arrivals Switch
                _buildSwitchTile(
                  title: "New arrivals",
                  value: _newArrivalsNotif,
                  onChanged: (val) {
                    setState(() {
                      _newArrivalsNotif = val;
                    });
                  },
                ),

                // Delivery status changes Switch
                _buildSwitchTile(
                  title: "Delivery status changes",
                  value: _deliveryStatusNotif,
                  onChanged: (val) {
                    setState(() {
                      _deliveryStatusNotif = val;
                    });
                  },
                ),
                const SizedBox(height: 36),
              ],
            ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          Switch(
            value: value,
            activeColor: Colors.green,
            activeTrackColor: Colors.green.shade100,
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade200,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
