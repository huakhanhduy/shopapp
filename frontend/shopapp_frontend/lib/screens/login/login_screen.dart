import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  void _checkLoginStatus() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    }
  }

  void _socialLogin(String provider) async {
    try {
      String email = "";
      String providerId = "";
      String firstName = "";
      String lastName = "";

      if (provider == "google") {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
          clientId: '803658319002-54q9s6jqnh5hatlm00b002180n3t80j3.apps.googleusercontent.com',
        );
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return; // User cancelled
        
        email = googleUser.email;
        providerId = googleUser.id;
        final String displayName = googleUser.displayName ?? "";
        final parts = displayName.split(" ");
        firstName = parts.isNotEmpty ? parts.first : "Google";
        lastName = parts.length > 1 ? parts.sublist(1).join(" ") : "User";
      } else if (provider == "facebook") {
        final LoginResult result = await FacebookAuth.instance.login(
          permissions: ['public_profile', 'email'],
        );
        if (result.status == LoginStatus.success) {
          final userData = await FacebookAuth.instance.getUserData();
          email = userData['email'] ?? "${userData['id']}@facebook.com";
          providerId = userData['id'] ?? "";
          final String name = userData['name'] ?? "";
          final parts = name.split(" ");
          firstName = parts.isNotEmpty ? parts.first : "Facebook";
          lastName = parts.length > 1 ? parts.sublist(1).join(" ") : "User";
        } else if (result.status == LoginStatus.cancelled) {
          return;
        } else {
          throw Exception(result.message ?? "Đăng nhập Facebook thất bại");
        }
      } else {
        throw Exception("Provider không hỗ trợ");
      }

      if (email.isEmpty || providerId.isEmpty) {
        throw Exception("Không thể lấy thông tin tài khoản");
      }

      await Provider.of<AuthProvider>(context, listen: false).socialLogin(
        email: email,
        provider: provider,
        providerId: providerId,
        firstName: firstName,
        lastName: lastName,
      );
      
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    const primaryColor = Color(0xffDB3022);

    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Đăng nhập",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) => val != null && val.contains("@") ? null : "Email không hợp lệ",
                ),
                const SizedBox(height: 12),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) => val != null && val.length >= 1 ? null : "Vui lòng nhập mật khẩu",
                ),
                const SizedBox(height: 16),

                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text(
                      "Quên mật khẩu?",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "ĐĂNG NHẬP",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Navigate to register screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Chưa có tài khoản? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        "Đăng ký ngay",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),

                // Social logins
                Center(
                  child: Column(
                    children: [
                      const Text(
                        "Hoặc đăng nhập nhanh bằng",
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialButton(
                            "google",
                            () => _socialLogin("google"),
                          ),
                          const SizedBox(width: 16),
                          _socialButton(
                            "facebook",
                            () => _socialLogin("facebook"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String type, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              type == "google" ? Icons.g_mobiledata : Icons.facebook,
              color: type == "google" ? Colors.red : Colors.blue[900],
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              type == "google" ? "Google" : "Facebook",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
