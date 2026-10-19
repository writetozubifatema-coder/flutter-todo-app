import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'get_started_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  final AuthService _authService = AuthService();

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _loginWithEmail() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showMessage("Please enter email & password");
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authService.loginWithEmail(
        emailController.text,
        passwordController.text,
      );

      // ✅ Navigate to GetStarted
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GetStartedScreen()),
        );
      }
    } 
    catch (e) {
  String msg = "Login failed";

  if (e.toString().contains("invalid-credential")) {
    msg = "Wrong email or password ❌";
  } else if (e.toString().contains("user-not-found")) {
    msg = "No user found with this email ❌";
  } else if (e.toString().contains("wrong-password")) {
    msg = "Wrong password ❌";
  }

  _showMessage(msg);
}
finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => isLoading = true);

    try {
      await _authService.signInWithGoogle();

      // ✅ Navigate to GetStarted
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GetStartedScreen()),
        );
      }
    } catch (e) {
      _showMessage("Google Sign-In failed: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),

                // ✅ Circular logo image
                Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.height * 0.25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/logo.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Login to continue managing your tasks!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 30),

                // Email Field
                _customTextField(
                  controller: emailController,
                  hint: "Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 18),

                // Password Field
                _customTextField(
                  controller: passwordController,
                  hint: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  hidePassword: hidePassword,
                  onTogglePassword: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                ),

                const SizedBox(height: 25),

                // ✅ Email Login Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _loginWithEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2CC7B8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 14),

                // ✅ Google Login Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: isLoading ? null : _loginWithGoogle,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Image.asset(
      "assets/images/google.png",
      height: 22,
    ),
    const SizedBox(width: 10),

    Flexible(
      child: Text(
        "Continue with Google",
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    ),
  ],
),

                  ),
                ),

                const SizedBox(height: 18),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      _showMessage("Register screen will be added later ✅");
                    },
                    child: const Text(
                      "Don’t have an account? Create one",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool hidePassword = true,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword ? hidePassword : false,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.black54),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black45),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: onTogglePassword,
                  icon: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black54,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
