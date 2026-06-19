import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/api_constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isNameValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      final valid = _nameController.text.trim().isNotEmpty;
      if (valid != _isNameValid) {
        setState(() {
          _isNameValid = valid;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isGoogleConfigured() {
    return ApiConstants.googleClientId != "YOUR_GOOGLE_CLIENT_ID" && ApiConstants.googleClientId.isNotEmpty;
  }

  bool _isFacebookConfigured() {
    return ApiConstants.facebookAppId != "YOUR_FACEBOOK_APP_ID" && ApiConstants.facebookAppId.isNotEmpty;
  }

  GoogleSignIn _getGoogleSignInInstance() {
    return GoogleSignIn(
      clientId: _isGoogleConfigured() ? ApiConstants.googleClientId : null,
      scopes: ['email', 'profile'],
    );
  }

  void _registerWithGoogle() async {
    try {
      final googleSignIn = _getGoogleSignInInstance();
      try {
        await googleSignIn.signOut();
      } catch (_) {}
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        if (!mounted) return;
        final nameParts = googleUser.displayName?.split(" ") ?? ["Google", "User"];
        final firstName = nameParts.first;
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";
        
        await Provider.of<AuthProvider>(context, listen: false).socialRegister(
          email: googleUser.email,
          provider: "google",
          providerId: googleUser.id,
          firstName: firstName,
          lastName: lastName,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đăng ký thành công, vui lòng đăng nhập")),
          );
          Navigator.pop(context); // Go back to login
        }
      }
    } catch (e) {
      debugPrint("Google Registration Error: $e");
      if (mounted) {
        final errMsg = e.toString();
        if (errMsg.contains("Tài khoản đã tồn tại") || errMsg.contains("đã tồn tại") || errMsg.contains("exist")) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tài khoản đã tồn tại")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi Google Registration: $e")),
          );
        }
      }
    }
  }

  void _registerWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );
      
      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();
        if (!mounted) return;
        final providerId = userData['id'] as String? ?? "fb_${DateTime.now().millisecondsSinceEpoch}";
        final email = userData['email'] as String? ?? "${providerId}@facebook.com";
        final name = userData['name'] as String? ?? "Facebook User";
        
        final nameParts = name.split(" ");
        final firstName = nameParts.first;
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";
 
        await Provider.of<AuthProvider>(context, listen: false).socialRegister(
          email: email,
          provider: "facebook",
          providerId: providerId,
          firstName: firstName,
          lastName: lastName,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đăng ký thành công, vui lòng đăng nhập")),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception("Facebook Registration status: ${result.status}");
      }
    } catch (e) {
      debugPrint("Facebook Registration Error: $e");
      if (mounted) {
        final errMsg = e.toString();
        if (errMsg.contains("Tài khoản đã tồn tại") || errMsg.contains("đã tồn tại") || errMsg.contains("exist")) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tài khoản đã tồn tại")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi Facebook Registration: $e")),
          );
        }
      }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final fullName = _nameController.text.trim();
      final parts = fullName.split(" ");
      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.sublist(1).join(" ") : parts.first;

      await Provider.of<AuthProvider>(context, listen: false).register(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: "",
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công, vui lòng đăng nhập")),
      );
      Navigator.pop(context); // Quay lại trang đăng nhập
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    }
  }

  Widget _buildCardTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildSocialButton({required String iconPath, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            iconPath,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    const primaryColor = Color(0xffDB3022);

    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Sign up",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Name
                _buildCardTextField(
                  controller: _nameController,
                  labelText: "Name",
                  suffixIcon: _isNameValid
                      ? const Icon(Icons.check, color: Color(0xff2AA952), size: 22)
                      : null,
                  validator: (val) => val == null || val.isEmpty ? "Please enter your name" : null,
                ),
                const SizedBox(height: 12),

                // Email
                _buildCardTextField(
                  controller: _emailController,
                  labelText: "Email",
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val != null && val.contains("@") ? null : "Invalid email",
                ),
                const SizedBox(height: 12),

                // Password
                _buildCardTextField(
                  controller: _passwordController,
                  labelText: "Password",
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.grey, size: 20),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (val) => val != null && val.length >= 6 ? null : "Password must be at least 6 characters",
                ),
                const SizedBox(height: 16),

                // Redirect link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.east,
                          color: primaryColor,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: primaryColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "SIGN UP",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                  ),
                ),
                const SizedBox(height: 50),

                // Or register with social
                const Center(
                  child: Text(
                    "Or sign up with social account",
                    style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 16),

                // Social buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      iconPath: "assets/icons/gg.png",
                      onTap: _registerWithGoogle,
                    ),
                    const SizedBox(width: 16),
                    _buildSocialButton(
                      iconPath: "assets/icons/fb.png",
                      onTap: _registerWithFacebook,
                    ),
                  ],
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
