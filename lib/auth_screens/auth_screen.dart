import 'package:cashflow/back/auth_service/user_service.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  bool _isNameInputVisible = true;
  bool _isEmailInputVisible = false;
  bool _isPasswordInputVisible = false;
  AuthService _authService = new AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _updateAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateAnimation({bool isBack = false}) {
    // Применяем правильную анимацию в зависимости от флага isBack
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: _isNameInputVisible
          ? const Offset(-1.0, 0.0) // Переход с имени на почту (слева направо)
          : _isEmailInputVisible
              ? (isBack
                  ? const Offset(1.0, 0.0)
                  : const Offset(
                      -1.0, 0.0)) // Почта (слева направо или справа налево)
              : const Offset(
                  1.0, 0.0), // Переход с пароля на почту (справа налево)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _showEmailField() async {
    await _controller.forward();
    setState(() {
      _isEmailInputVisible = true;
      _isNameInputVisible = false;
      _updateAnimation(
          isBack: false); // Обычная анимация при переходе с имени на почту
    });
    _controller.reset();
  }

  Future<void> _showPasswordField() async {
    await _controller.forward();
    setState(() {
      _isPasswordInputVisible = true;
      _isEmailInputVisible = false;
      _updateAnimation(
          isBack: false); // Обычная анимация при переходе с почты на пароль
    });
    _controller.reset();
  }

  Future<void> _showNameField() async {
    await _controller.forward();
    setState(() {
      _isNameInputVisible = true;
      _isEmailInputVisible = false;
      _updateAnimation(
          isBack: true); // Обратная анимация при переходе с пароля на почту
    });
    _controller.reset();
  }

  Future<void> _showEmailFieldBack() async {
    await _controller.forward();
    setState(() {
      _isEmailInputVisible = true;
      _isPasswordInputVisible = false;
      _updateAnimation(
          isBack: true); // Обратная анимация при переходе с пароля на почту
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/auth_back.gif'),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _offsetAnimation,
            child: _isNameInputVisible
                ? _buildNameInput()
                : _isEmailInputVisible
                    ? _buildEmailInput()
                    : _buildPasswordInput(),
          ),
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            style: TextStyle(color: Colors.orange, fontSize: 24),
            decoration: const InputDecoration(
              labelText: 'Имя',
              labelStyle: TextStyle(color: Colors.orange, fontSize: 20),
              fillColor: Colors.black,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Colors.orange),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Colors.orange),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Colors.orange),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  _showEmailField();
                }
              },
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailInput() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            style: TextStyle(color: Colors.orange, fontSize: 24),
            decoration: const InputDecoration(
              labelText: 'Почта',
              labelStyle: TextStyle(color: Colors.orange, fontSize: 20),
              fillColor: Colors.black,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Colors.orange),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Colors.orange),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Colors.orange),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: _showNameField,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
            FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: _showPasswordField,
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          TextFormField(
            obscureText: true,
            controller: _passwordController,
            style: TextStyle(color: Colors.orange, fontSize: 24),
            decoration: const InputDecoration(
              labelText: 'Пароль',
              labelStyle: TextStyle(color: Colors.orange, fontSize: 20),
              fillColor: Colors.black,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Colors.orange),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Colors.orange),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Colors.orange),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton(
                backgroundColor: Colors.orange,
                onPressed: _showEmailFieldBack,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
              ),
              FloatingActionButton.extended(
                backgroundColor: const Color.fromARGB(255, 255, 153, 0),
                onPressed: () {
                  // Handle authorization logic here
                  _authService.signUp(_nameController.text,
                      _emailController.text, _passwordController.text);
                },
                label: const Text(
                  'Авторизоваться',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
