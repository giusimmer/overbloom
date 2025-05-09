import 'package:flutter/material.dart';
import 'package:overbloom/components/base_screen.dart';
import '../Initial/initial_screen.dart';
import '../ResetPassword/reset_password_screen.dart';
import '../../controller/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  final bool isLogin;

  const AuthScreen({super.key, required this.isLogin});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final AuthController _authController = AuthController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureText = true;
  bool _obscureConfirmText = true;

  void _handleAuth() async {
    String? errorMessage;

    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showToast("Preencha todos os campos!");
      return;
    }

    if (!widget.isLogin) {
      if (_userNameController.text.trim().isEmpty || _confirmPasswordController.text.trim().isEmpty) {
        _showToast("Preencha todos os campos!");
        return;
      }
      if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
        _showToast("As senhas não coincidem!");
        return;
      }
      errorMessage = await _authController.signUp(
        _userNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      errorMessage = await _authController.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }

    if (errorMessage == null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => InitialScreen()),
      );
    } else {
      _showToast(errorMessage!);
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      fundo: "auth_fundo.png",
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Image.asset('assets/images/icon/arrow_back.png', width: 50, height: 50),
                ),
              ),
              Image.asset('assets/images/cenario/name_app.png'),
              const SizedBox(height: 20),

              if (!widget.isLogin)
                _buildTextField(controller: _userNameController, label: "Username", icon: Icons.person),

              _buildTextField(controller: _emailController, label: "Email", icon: Icons.alternate_email, keyboardType: TextInputType.emailAddress),

              _buildTextField(
                controller: _passwordController,
                label: "Senha",
                icon: _obscureText ? Icons.visibility_off : Icons.visibility,
                obscureText: _obscureText,
                onIconPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),

              if (!widget.isLogin)
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: "Confirmar Senha",
                  icon: _obscureConfirmText ? Icons.visibility_off : Icons.visibility,
                  obscureText: _obscureConfirmText,
                  onIconPressed: () {
                    setState(() {
                      _obscureConfirmText = !_obscureConfirmText;
                    });
                  },
                ),

              if (widget.isLogin)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordScreen())),
                    child: const Text(
                      "Esqueceu sua senha?",
                      style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: _handleAuth,
                child: Image.asset(
                  widget.isLogin ? 'assets/images/buttons/entrar_button.png' : 'assets/images/buttons/criar_button.png',
                  width: 250,
                  height: 75,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onIconPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xff6B74A7), fontSize: 17, fontWeight: FontWeight.bold),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          suffixIcon: onIconPressed != null ? IconButton(icon: Icon(icon), onPressed: onIconPressed) : Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
