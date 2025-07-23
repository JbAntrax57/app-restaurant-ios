import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/localization.dart';
import '../../../application/providers/auth_provider.dart';
import '../../../core/router.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'cliente';
  
  final List<String> _roles = ['cliente', 'duenio', 'repartidor', 'admin'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<bool> _isEmailOrPhoneTaken(String email, String phone) async {
    final supabase = Supabase.instance.client;
    final result = await supabase
        .from('usuarios')
        .select('id')
        .or('email.eq.$email,telephone.eq.$phone')
        .maybeSingle();
    return result != null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Validar unicidad de correo y teléfono
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final taken = await _isEmailOrPhoneTaken(email, phone);
      if (taken) {
        _showErrorSnackBar('El correo o el teléfono ya están registrados.');
        setState(() { _isLoading = false; });
        return;
      }
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        email: email,
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _selectedRole,
        phone: phone,
        address: _addressController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        _showSuccessSnackBar('Usuario registrado exitosamente');
        _navigateByRole(_selectedRole);
      } else {
        _showErrorSnackBar('Error al registrar usuario');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Error al registrar: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateByRole(String role) {
    switch (role.toLowerCase()) {
      case 'cliente':
        context.go('/cliente');
        break;
      case 'duenio':
        context.go('/duenio');
        break;
      case 'repartidor':
        context.go('/repartidor');
        break;
      case 'admin':
        context.go('/admin');
        break;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Registro'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Título
                Text(
                  'Crear cuenta',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                Text(
                  'Completa los datos para registrarte',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Campo de nombre
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Nombre completo',
                  hintText: 'Tu nombre completo',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    if (value.length < 2) {
                      return 'El nombre debe tener al menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Campo de email
                CustomTextField(
                  controller: _emailController,
                  labelText: AppLocalization.getString('email'),
                  hintText: 'ejemplo@correo.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalization.getString('validation_required');
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return AppLocalization.getString('validation_email');
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Campo de contraseña
                CustomTextField(
                  controller: _passwordController,
                  labelText: AppLocalization.getString('password'),
                  hintText: '••••••••',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalization.getString('validation_required');
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Campo de confirmar contraseña
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirmar contraseña',
                  hintText: '••••••••',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirma tu contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Campo de teléfono
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Teléfono',
                  hintText: '555-123-4567',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El teléfono es requerido';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Campo de dirección
                CustomTextField(
                  controller: _addressController,
                  labelText: 'Dirección',
                  hintText: 'Tu dirección completa',
                  maxLines: 2,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                
                const SizedBox(height: 16),
                
                // Selector de rol
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Rol',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  items: _roles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona un rol';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Botón de registro
                CustomButton(
                  onPressed: _isLoading ? null : _register,
                  text: _isLoading ? 'Registrando...' : 'Registrarse',
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Enlace para ir a login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes cuenta?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 