import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final authProvider = context.read<AuthProvider>();

    if (_isSignUp) {
      await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
    } else {
      await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.systemBackground,
      child: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  const Icon(
                    CupertinoIcons.money_dollar_circle_fill,
                    size: 80,
                    color: AppColors.systemGreen,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SantaFe',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: AppColors.label,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tus finanzas en orden',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: AppColors.secondaryLabel,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (_isSignUp) ...[
                    _buildTextField(
                      controller: _nameController,
                      placeholder: 'Nombre',
                      icon: CupertinoIcons.person,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildTextField(
                    controller: _emailController,
                    placeholder: 'Correo electrónico',
                    icon: CupertinoIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    placeholder: 'Contraseña',
                    icon: CupertinoIcons.lock,
                    obscureText: _obscurePassword,
                    suffix: GestureDetector(
                      onTap: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        color: AppColors.secondaryLabel,
                        size: 20,
                      ),
                    ),
                  ),
                  if (authProvider.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.systemRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        authProvider.error!,
                        style: const TextStyle(
                          color: AppColors.systemRed,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  CupertinoButton.filled(
                    onPressed: authProvider.isLoading ? null : _submit,
                    borderRadius: BorderRadius.circular(12),
                    child: authProvider.isLoading
                        ? const CupertinoActivityIndicator(
                            color: CupertinoColors.white,
                          )
                        : Text(
                            _isSignUp ? 'Crear cuenta' : 'Iniciar sesión',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () => setState(() {
                            _isSignUp = !_isSignUp;
                            authProvider.error;
                          }),
                    child: Text(
                      _isSignUp
                          ? '¿Ya tienes cuenta? Inicia sesión'
                          : '¿No tienes cuenta? Regístrate',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.systemGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: CupertinoButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => authProvider.skipLogin(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: const Text(
                        'Continuar como invitado',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryLabel,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(icon, color: AppColors.secondaryLabel, size: 20),
          ),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              obscureText: obscureText,
              keyboardType: keyboardType,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: const BoxDecoration(),
              style: const TextStyle(color: AppColors.label),
              placeholderStyle: const TextStyle(color: AppColors.tertiaryLabel),
            ),
          ),
          if (suffix != null)
            Padding(padding: const EdgeInsets.only(right: 12), child: suffix),
        ],
      ),
    );
  }
}
