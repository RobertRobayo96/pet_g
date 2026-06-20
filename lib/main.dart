import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:petg/features/auth/data/presentation/screens/register_screen.dart';
import 'package:petg/features/cuidador_dashboard/presentation/main_cuidador_screen.dart';
import 'package:petg/features/home_map/presentation/main_home_owner_screen.dart';

import 'features/auth/data/auth_local_repository.dart';
import 'features/auth/data/auth_remote_repository.dart';
import 'features/auth/data/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/presentation/bloc/auth_event.dart';
import 'features/auth/data/presentation/bloc/auth_state.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Le pasamos las opciones de configuración reales generadas de tu proyecto
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("🔥 Firebase inicializado con éxito y conectado a la nube");
  } catch (e) {
    print("⚠️ Error al conectar Firebase: $e");
  }

  // Inicializar Hive para caché ligera
  await Hive.initFlutter();
  await Hive.openBox('app_preferences');

  // Inicializar OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("TU_ONESIGNAL_APP_ID_AQUI");
  OneSignal.Notifications.requestPermission(true);

  runApp(const PetGApp());
}

class PetGApp extends StatelessWidget {
  const PetGApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyectamos el AuthBloc en la raíz de la app para que esté disponible en el Login
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            remoteRepository: AuthRemoteRepository(),
            localRepository: AuthLocalRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'PetG',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A), // Azul institucional
            primary: const Color(0xFF1E3A8A),
            secondary: const Color(0xFF10B981), // Verde para acentos de éxito
            background: const Color(0xFFF3F4F6), // Gris claro armónico para fondos
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authRepository = AuthLocalRepository();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = await _authRepository.getToken();
    final role = _authRepository.getUserRole();

    if (!mounted) return;

    if (token != null && role != null) {
      if (role == 'DUEÑO') {
        _navigateTo(const MainCuidadorScreen());
      } else if (role == 'CUIDADOR') {
        _navigateTo(const MainCuidadorScreen());
      }
    } else {
      _navigateTo(const LoginScreen());
    }
  }

  void _navigateTo(Widget targetScreen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1E3A8A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'PetG',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: 3.0,
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// PANTALLA DE LOGIN CON DISEÑO ARMÓNICO Y MATERIAL 3
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Fondo gris claro relajante
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('¡Bienvenido, ${state.user.name}!'), backgroundColor: const Color(0xFF10B981)),
            );
            
            if (state.user.role == 'DUEÑO') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainHomeOwnerScreen())
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainCuidadorScreen())
              );
            }
          }
          
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.redAccent),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.pets, size: 65, color: Color(0xFF1E3A8A)),
                  const SizedBox(height: 12),
                  const Text(
                    'Ingresar a PetG',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Conectando confianza para tus mejores amigos',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 35),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1E3A8A)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor ingresa tu correo';
                      if (!value.contains('@')) return 'Ingresa un correo electrónico válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1E3A8A)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor ingresa tu contraseña';
                      if (value.length < 6) return 'La contraseña debe tener mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              LoginSubmitted(
                                _emailController.text.trim(),
                                _passwordController.text,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Iniciar Sesión',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // 🛠️ 2. AGREGAMOS LA NAVEGACIÓN EN EL ENLACE DE REGISTRO
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      '¿No tienes cuenta? Regístrate aquí',
                      style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}