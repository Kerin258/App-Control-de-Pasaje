import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/expense_provider.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import '../utils/preferences_service.dart';

/// Pantalla de inicio de sesión y registro de usuario
///
/// Primera pantalla que ve el usuario al abrir la app por primera vez.
/// Permite registrar:
/// - Nombre y apellido
/// - Edad (usando selector nativo según la plataforma)
/// - Contraseña con validación de seguridad
/// - Foto de perfil opcional
/// - Estado de estudiante
///
/// Incluye animación de partículas en el fondo para mejor estética.
///
/// Desarrollado por: Kevin y kerin
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _prefs = PreferencesService();

  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  bool _isRegistering = false;
  String? _profileImagePath;
  int _selectedAge = 18; // Default age

  bool _hasUppercase = false;
  bool _hasMinLength = false;
  bool _hasSymbol = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordValidation);

    // Initialize animation for background
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generate random particles
    for (int i = 0; i < 40; i++) {
      _particles.add(
        Particle(
          position: Offset(
            _random.nextDouble() * 400,
            _random.nextDouble() * 800,
          ),
          speed: _random.nextDouble() * 0.6 + 0.1,
          radius: _random.nextDouble() * 3 + 1,
          opacity: _random.nextDouble() * 0.15 + 0.05,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _updatePasswordValidation() {
    final text = _passwordController.text;
    setState(() {
      _hasMinLength = text.length >= 6;
      _hasUppercase = text.contains(RegExp(r'[A-Z]'));
      _hasSymbol = text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al seleccionar la imagen')),
      );
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (!_hasMinLength || !_hasUppercase || !_hasSymbol) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Por favor cumple con todos los requisitos de la contraseña',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final provider = Provider.of<ExpenseProvider>(context, listen: false);

      if (_isRegistering) {
        await provider.updateUserName(_nameController.text);
        await provider.updateUserSurname(_surnameController.text);
        await provider.updateUserAge(_ageController.text);
        if (_profileImagePath != null) {
          await provider.updateProfileImage(_profileImagePath!);
        }
      } else {
        await provider.updateUserName(_nameController.text);
      }

      final budget = await _prefs.getBudget();

      if (!mounted) return;

      if (budget > 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  Widget _buildValidationIndicator(String text, bool isValid) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isValid ? Colors.green : Colors.grey.shade300,
            border: Border.all(
              color: isValid ? Colors.green : Colors.grey,
              width: 1,
            ),
          ),
          child:
              isValid
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.black87 : Colors.grey,
            fontSize: 12,
            fontWeight: isValid ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  ImageProvider? _getImageProvider() {
    if (_profileImagePath == null) return null;
    if (kIsWeb) {
      return NetworkImage(_profileImagePath!);
    } else {
      return FileImage(File(_profileImagePath!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: Stack(
          children: [
            // Animated Background
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: ParticlePainter(
                    particles: _particles,
                    animationValue: _controller.value,
                  ),
                );
              },
            ),

            // Main Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isRegistering) ...[
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.deepPurple.shade100,
                            backgroundImage: _getImageProvider(),
                            child:
                                _profileImagePath == null
                                    ? const Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: Colors.deepPurple,
                                    )
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Configura tu Perfil',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ingresa tus datos personales',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.directions_bus_filled_rounded,
                          size: 80,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Control de Pasaje',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bienvenido de nuevo',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                      if (_isRegistering) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _surnameController,
                          decoration: InputDecoration(
                            labelText: 'Apellido',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu apellido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 250,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Container(
                                        color: Colors.grey.shade100,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'Cancelar',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _ageController.text =
                                                      _selectedAge.toString();
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'Listo',
                                                style: TextStyle(
                                                  color: Colors.deepPurple,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: CupertinoPicker(
                                          itemExtent: 32.0,
                                          onSelectedItemChanged: (int index) {
                                            setState(() {
                                              _selectedAge = 13 + index;
                                            });
                                          },
                                          scrollController:
                                              FixedExtentScrollController(
                                                initialItem: _selectedAge - 13,
                                              ),
                                          children: List<Widget>.generate(
                                            87, // 99 - 13 + 1
                                            (int index) {
                                              return Center(
                                                child: Text(
                                                  '${13 + index}',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _ageController,
                              decoration: InputDecoration(
                                labelText: 'Edad',
                                prefixIcon: const Icon(Icons.calendar_today),
                                suffixIcon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.deepPurple,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor selecciona tu edad';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu contraseña';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildValidationIndicator(
                            '6+ Caracteres',
                            _hasMinLength,
                          ),
                          _buildValidationIndicator('Mayúscula', _hasUppercase),
                          _buildValidationIndicator('Símbolo', _hasSymbol),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              (_hasMinLength && _hasUppercase && _hasSymbol)
                                  ? _submit
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _isRegistering ? 'Registrarse' : 'Iniciar Sesión',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isRegistering = !_isRegistering;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            text:
                                _isRegistering
                                    ? '¿Ya tienes cuenta? '
                                    : '¿Primera vez? ',
                            style: const TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text:
                                    _isRegistering
                                        ? 'Inicia Sesión'
                                        : 'Configura tu perfil',
                                style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Particle {
  Offset position;
  double speed;
  double radius;
  double opacity;

  Particle({
    required this.position,
    required this.speed,
    required this.radius,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter({required this.particles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint =
          Paint()
            ..color = Colors.deepPurple.withValues(alpha: particle.opacity)
            ..style = PaintingStyle.fill;

      // Move particle up
      double dy =
          particle.position.dy - (animationValue * 150 * particle.speed);

      // Wrap around
      if (dy < 0) {
        dy = size.height + dy % size.height;
      } else {
        dy = dy % size.height;
      }

      // Scale X to screen width
      double dx = (particle.position.dx / 400) * size.width;

      canvas.drawCircle(Offset(dx, dy), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
