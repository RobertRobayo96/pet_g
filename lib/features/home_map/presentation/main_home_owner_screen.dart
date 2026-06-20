
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:petg/features/home_map/presentation/bloc/home_map_bloc.dart';
import 'package:petg/features/home_map/presentation/bloc/home_map_event.dart';

import 'package:petg/core/data/datasources/request_remote_data_source.dart';
import 'package:petg/features/home_map/presentation/screens/seguimiento_servicio_screen.dart';
import 'package:petg/main.dart'; 

class MainHomeOwnerScreen extends StatelessWidget {
  const MainHomeOwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeMapBloc()..add(LoadCurrentLocation()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        
        //  MENÚ (DRAWER LATERAL)
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF1E3A8A),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, color: Colors.white, size: 40),
                    SizedBox(height: 12),
                    Text(
                      'PetG App',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Panel de Control',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Color(0xFF1E3A8A)),
                title: const Text('Inicio'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF1E3A8A)),
                title: const Text('Mi Perfil'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Color(0xFF1E3A8A)),
                title: const Text('Historial de Servicios'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  final box = await Hive.openBox('app_preferences');
                  await box.clear(); 

                  if (!context.mounted) return;

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),

        //  NAV BAR SUPERIOR 
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E3A8A),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Row(
            children: [
              Text(
                'PetG - Panel Dueño', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              tooltip: 'Notificaciones',
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),

        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BIENVENIDA / HERO SECTION
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('¡Hola! 👋', style: TextStyle(color: Colors.white70, fontSize: 15)),
                    SizedBox(height: 6),
                    Text(
                      '¿Qué servicio necesita tu consentido hoy?', 
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 13, 
                        fontWeight: FontWeight.w600, 
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. TÍTULO DE SECCIÓN
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Servicios Disponibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ),
              
              const SizedBox(height: 16),

              // CUADRÍCULA DE SERVICIOS (GRID)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildGridCard(
                        context,
                        title: 'Cuidadores',
                        subtitle: 'Estadía y cuidado',
                        icon: Icons.gite,
                        iconColor: const Color(0xFF3B82F6),
                        onTap: () => _openRequestModal(context),
                      ),
                      _buildGridCard(
                        context,
                        title: 'Paseadores',
                        subtitle: 'Rutas seguras',
                        icon: Icons.directions_walk,
                        iconColor: const Color(0xFF10B981),
                        onTap: () => _openRequestModal(context),
                      ),
                      _buildGridCard(
                        context,
                        title: 'Veterinarias',
                        subtitle: 'Asistencia 24/7',
                        icon: Icons.local_hospital,
                        iconColor: const Color(0xFFEF4444),
                        onTap: () {},
                      ),
                      _buildGridCard(
                        context,
                        title: 'Tiendas',
                        subtitle: 'Snacks y juguetes',
                        icon: Icons.shopping_bag,
                        iconColor: const Color(0xFFF59E0B),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),

              
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('solicitudes').doc('active_service').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'PENDIENTE';
                  final petName = data['petName'] ?? 'tu mascota'; 
                  
                
                  final payment = data['payment'] ?? data['totalPayment'] ?? '0';

                  //  CASO: CUIDADOR PIDE CONFIRMACIÓN
                  if (status == 'A_CONFIRMAR') {
                    return _buildPersistentStatusCard(
                      color: Colors.orange.shade50,
                      borderColor: Colors.orange.shade400,
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pets, color: Colors.orange, size: 28),
                              SizedBox(width: 8),
                              Text(
                                '¡Llegaron a casa! 👋',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'El cuidador indica que completó el servicio para $petName. Por favor, confirma si recibiste a tu mascota.',
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981), // Verde éxito
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () async {
                                    // El dueño confirma la entrega y cierra definitivamente el ciclo
                                    await FirebaseFirestore.instance
                                        .collection('solicitudes')
                                        .doc('active_service')
                                        .update({'status': 'FINALIZADO'});
                                  },
                                  child: const Text('Confirmar Entrega', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  // CASO: EL CUIDADOR LLEGÓ AL PUNTO DE ENCUENTRO INICIAL
                  if (status == 'LLEGÓ') {
                    return _buildPersistentStatusCard(
                      color: const Color(0xFFEFF6FF),
                      borderColor: const Color(0xFF3B82F6),
                      child: Column(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF10B981), size: 40),
                          const SizedBox(height: 8),
                          Text('¡El cuidador para $petName ha llegado!', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)), textAlign: TextAlign.center),
                          Text('Total a transferir: \$$payment COP', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance.collection('solicitudes').doc('active_service').update({'status': 'EN_PROGRESO'});
                                  },
                                  child: const Text('Iniciar Servicio', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance.collection('solicitudes').doc('active_service').delete();
                                  },
                                  child: const Text('Cancelar'),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  }

                  // CASO: EL SERVICIO YA ESTÁ EN CURSO
                  if (status == 'EN_PROGRESO') {
                    return _buildPersistentStatusCard(
                      color: const Color(0xFFECFDF5),
                      borderColor: const Color(0xFF10B981),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.run_circle, color: Color(0xFF10B981), size: 32),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$petName está en servicio activo 🐾', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                                    const Text('El cuidador inició la actividad.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A8A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.analytics_outlined, size: 16),
                                  label: const Text('Seguimiento en Vivo'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SeguimientoServicioScreen(petName: petName, cuidadorName: 'Carlos M.'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF065F46),
                                  side: const BorderSide(color: Color(0xFF065F46)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () async {
                                  await FirebaseFirestore.instance.collection('solicitudes').doc('active_service').delete();
                                },
                                child: const Text('Terminar'),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  }

                  // Si el estado es FINALIZADO o no existe la solicitud, el banner no ocupa espacio en pantalla
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color iconColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: (0.04 * 255).round().toDouble()), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.grey.shade100, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconColor.withValues(alpha: (0.1 * 255).round().toDouble()), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersistentStatusCard({required Color color, required Color borderColor, required Widget child}) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: (0.05 * 255).round().toDouble()), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: child,
    );
  }

  void _openRequestModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RequestServiceFormModal(),
    );
  }
}

class RequestServiceFormModal extends StatefulWidget {
  const RequestServiceFormModal({super.key});

  @override
  State<RequestServiceFormModal> createState() => _RequestServiceFormModalState();
}

class _RequestServiceFormModalState extends State<RequestServiceFormModal> {
  String _selectedPet = 'Max'; 
  int _hours = 2; 
  final int _pricePerHour = 12000; 

  @override
  Widget build(BuildContext context) {
    int totalPayable = _hours * _pricePerHour;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Configura tu Solicitud', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          const Text('¿Cuál de tus consentidos necesita cuidado?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildPetOption('Max', Icons.pets),
              const SizedBox(width: 12),
              _buildPetOption('Loki', Icons.pets),
            ],
          ),
          const SizedBox(height: 24),
          const Text('¿Por cuántas horas requieres el servicio?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Duración estimada:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Row(
                children: [
                  IconButton(
                    onPressed: _hours > 1 ? () => setState(() => _hours--) : null,
                    icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF1E3A8A), size: 28),
                  ),
                  Text('$_hours hrs', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => setState(() => _hours++),
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1E3A8A), size: 28),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total a pagar:', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
              Text(
                '\$${totalPayable.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
            ],
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () async { 
              final dataSource = RequestRemoteDataSource();
              try {
                await dataSource.crearSolicitud(
                  petName: _selectedPet,   
                  hours: _hours,          
                  totalPayment: totalPayable.toString(), 
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Solicitud enviada a Firebase con éxito!'), backgroundColor: Colors.green),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al enviar: $e')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Confirmar y Enviar Solicitud', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildPetOption(String name, IconData icon) {
    final isSelected = _selectedPet == name;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPet = name),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade300, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : const Color(0xFF1E3A8A)),
              const SizedBox(width: 8),
              Text(name, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}