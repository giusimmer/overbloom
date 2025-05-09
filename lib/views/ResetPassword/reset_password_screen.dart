import 'package:flutter/material.dart';
import 'package:overbloom/controller/reset_password_controller.dart';
import 'package:overbloom/components/base_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final ResetPasswordController _controller = ResetPasswordController();
  final TextEditingController _emailController = TextEditingController();
  String _message = "";
  bool _isButtonDisabled = false;
  int _secondsRemaining = 0;

  void _updateMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  void _updateButtonState(bool isDisabled, int secondsRemaining) {
    setState(() {
      _isButtonDisabled = isDisabled;
      _secondsRemaining = secondsRemaining;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _controller.dispose();
    super.dispose();
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
                  icon: Image.asset(
                    'assets/images/icon/arrow_back.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
              Image.asset('assets/images/cenario/name_app.png'),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Digite seu e-mail para receber um link de redefinição de senha.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController,
                      label: "E-mail",
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    if (_message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          _message,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (_isButtonDisabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "Tente novamente em ${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')} min",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 25),
                    GestureDetector(
                      onTap: _isButtonDisabled
                          ? null
                          : () => _controller.resetPassword(
                        context: context,
                        emailController: _emailController,
                        updateMessage: _updateMessage,
                        updateButtonState: _updateButtonState,
                      ),
                      child: Opacity(
                        opacity: _isButtonDisabled ? 0.5 : 1.0,
                        child: Image.asset(
                          'assets/images/buttons/enviar_button.png',
                          width: 250,
                          height: 75,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xff6B74A7),
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        suffixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
