import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:petg/features/cuidador_dashboard/presentation/mapa_cuidador_screen.dart';
import 'package:petg/features/home_map/presentation/screens/ganancias_screen.dart';
import 'package:petg/features/home_map/presentation/screens/seguimiento_servicio_screen.dart';

import 'package:petg/main.dart'; 
// import 'package:petg/features/chat/presentation/chat_screen.dart'; 

import 'bloc/dashboard_bloc.dart';
import 'bloc/dashboard_event.dart';
import 'bloc/dashboard_state.dart';

class MainCuidadorScreen extends StatefulWidget {
  const MainCuidadorScreen({super.key});

  @override
  State<MainCuidadorScreen> createState() => _MainCuidadorScreenState();
}

class _MainCuidadorScreenState extends State<MainCuidadorScreen> {
  bool _localIsOnline = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc()..add(LoadDashboardData()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),

        // MENÚ LATERAL (DRAWER)
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF1E3A8A)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, color: Colors.white, size: 40),
                    SizedBox(height: 12),
                    Text(
                      'PetG - Cuidador',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Panel de Actividad',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard, color: Color(0xFF1E3A8A)),
                title: const Text('Solicitudes Activas'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF1E3A8A)),
                title: const Text('Mis Ganancias'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GananciasScreen()),
                  );
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

        // BARRA SUPERIOR (APPBAR)
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E3A8A),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white), 
          title: const Text('Panel de Cuidador', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          actions: [
            Row(
              children: [
                Text(
                  _localIsOnline ? 'CONECTADO' : 'DESCONECTADO', 
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)
                ),
                Switch(
                  value: _localIsOnline,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (value) {
                    setState(() {
                      _localIsOnline = value;
                    });
                    context.read<DashboardBloc>().add(ToggleAvailability(isOnline: value));
                  },
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
        
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is DashboardLoaded) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🌟 1. BANNER DE BIENVENIDA (Debajo de la barra)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, Cuidador! 👋',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Gestiona tus paseos, servicios y ayuda a las mascotas hoy.',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🛠️ 2. CUADRÍCULA / BANNER: ¿QUÉ NECESITAS?
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        '¿Qué necesitas revisar?',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.3,
                        children: [
                          _buildMenuCard(Icons.medical_services_outlined, 'Medicamentos', Colors.purple),
                          _buildMenuCard(Icons.local_hospital_outlined, 'Urgencias', Colors.red),
                          _buildMenuCard(Icons.bathtub_outlined, 'Baño y Estética', Colors.blue),
                          _buildMenuCard(Icons.directions_walk, 'Paseos Historial', Colors.orange),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🐾 3. SECCIÓN: SERVICIOS Y SOLICITUDES ACTIVAS
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Servicios y Solicitudes en curso',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (state.pendingRequests.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'No tienes solicitudes de cuidado activas en este momento.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      )
                    else
                      // Renderizado dinámico de las tarjetas del servicio
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.pendingRequests.length,
                        itemBuilder: (context, index) {
                          // Use dynamic to avoid static getter errors if the model differs
                          final dynamic request = state.pendingRequests[index];
                          final currentStatus = request.status.toUpperCase();

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Encabezado Tarjeta: Dueño + Precio
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Despliega el nombre del Dueño real mapeado en tu modelo o 'Dueño de PetG' si viene vacío
                                      Text(
                                        request.ownerName.isNotEmpty ? request.ownerName : 'Dueño de Mascota', 
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                      ),
                                     Text(
                                        '\$${request.totalPayment.toString().isNotEmpty ? request.totalPayment : '0'}', 
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  
                                  // Detalles del servicio
                                  Text('Mascota: ${request.petName.isNotEmpty ? request.petName : "Max 🐾"}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  // Se despliega dinámicamente el tiempo estimado recibido desde el cliente
                                  Text('Tiempo estimado solicitado: ${request.hours.toString().isNotEmpty ? request.hours : "2"} horas', style: const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 10),
                                  
                                  // Etiqueta de estado
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (currentStatus == 'PENDIENTE' || currentStatus == 'PENDING') ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Estado: $currentStatus', 
                                      style: TextStyle(fontWeight: FontWeight.bold, color: (currentStatus == 'PENDIENTE' || currentStatus == 'PENDING') ? Colors.orange : Colors.blue)
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // ACCIONES SINO HA SIDO ACEPTADO (PENDIENTE)
                                  if (currentStatus == 'PENDIENTE' || currentStatus == 'PENDING')
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.red.shade700,
                                              side: BorderSide(color: Colors.red.shade400),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            icon: const Icon(Icons.close, size: 18),
                                            label: const Text('Rechazar'),
                                            onPressed: () async {
                                              try {
                                                await FirebaseFirestore.instance.collection('solicitudes').doc('active_service').delete();
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud rechazada'), backgroundColor: Colors.red));
                                              } catch (e) {
                                                print("Error al rechazar: $e");
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF1E3A8A),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            icon: const Icon(Icons.assignment_turned_in, size: 18),
                                            label: const Text('Aceptar'),
                                            onPressed: () async {
                                              try {
                                                await FirebaseFirestore.instance.collection('solicitudes').doc('active_service').update({'status': 'ACEPTADO'});
                                                if (!context.mounted) return;
                                                Navigator.push(context, MaterialPageRoute(builder: (_) => MapaCuidadorScreen(petName: request.petName.isNotEmpty ? request.petName : "Max")));
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  
                                  // ACCIONES CUANDO EL SERVICIO YA ESTÁ EN PROGRESO (ACEPTADO)
                                  else if (currentStatus == 'ACEPTADO' || currentStatus == 'EN_PROGRESO' || currentStatus == 'EN PROGRESO')
                                    Column(
                                      children: [
                                        const SizedBox(height: 12),
                                        
                                        // 💬 BOTÓN DE MENSAJES (Ocupa todo el ancho ahora)
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF1E3A8A), // Azul oscuro institucional
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            icon: const Icon(Icons.analytics_outlined, size: 20), // Icono de monitoreo/seguimiento
                                            label: const Text('Ver Seguimiento del Servicio', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => SeguimientoServicioScreen(
                                                    // Pásale los datos dinámicos que requiera tu pantalla de seguimiento
                                                    petName: request.petName,
                                                    cuidadorName: request.ownerName,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 10),
                                        
                                        // 🏁 BOTÓN PARA FINALIZAR EL SERVICIO
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.orange, // Cambiamos a naranja por estado de espera
                                              side: const BorderSide(color: Colors.orange, width: 1.5),
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            icon: const Icon(Icons.av_timer, size: 20),
                                            label: const Text('Terminar y Avisar al Dueño', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                            onPressed: () async {
                                              bool? confirmar = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('¿Terminar el paseo?'),
                                                  content: Text('Se le enviará una notificación a ${request.ownerName} para que confirme la entrega de ${request.petName}.'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, false),
                                                      child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, true),
                                                      child: const Text('Sí, notificar', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirmar == true) {
                                                try {
                                                  // 🔄 PASO CLAVE: Cambiamos el estado a 'A_CONFIRMAR'
                                                  await FirebaseFirestore.instance
                                                      .collection('solicitudes')
                                                      .doc(request.id.isNotEmpty ? request.id : 'active_service')
                                                      .update({'status': 'A_CONFIRMAR'});

                                                  if (!context.mounted) return;
                                                  
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Solicitud de finalización enviada. Esperando confirmación del dueño... ⏳'), 
                                                      backgroundColor: Colors.orange
                                                    )
                                                  );
                                                  
                                                  context.read<DashboardBloc>().add(LoadDashboardData());
                                                } catch (e) {
                                                  print("Error al solicitar finalización: $e");
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }
            return const Center(child: Text('Error al cargar el panel.'));
          },
        ),
      ),
    );
  }

  // 🛠️ WIDGET AUXILIAR PARA RENDERIZAR LA CUADRÍCULA DE SERVICIOS ADICIONALES
  Widget _buildMenuCard(IconData icon, String title, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Acción del módulo complementario
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 18,
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}