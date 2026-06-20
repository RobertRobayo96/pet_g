import 'package:flutter/material.dart';

class GananciasScreen extends StatelessWidget {
  const GananciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Mis Ganancias',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 💰 CONTENEDOR PRINCIPAL DEL BALANCE
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 8),
              child: Column(
                children: [
                  const Text(
                    'Balance Disponible',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '\$150.000',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), // Verde éxito
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.account_balance, size: 20),
                    label: const Text(
                      'Retirar a mi Cuenta',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Procesando solicitud de retiro a tu cuenta bancaria...'),
                          backgroundColor: Color(0xFF1E3A8A),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 📊 TARJETAS DE MÉTRICAS RESUMIDAS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildStatCard(
                    context,
                    title: 'Servicios',
                    value: '12',
                    icon: Icons.pets,
                    iconColor: const Color(0xFF1E3A8A),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context,
                    title: 'Propinas',
                    value: '\$15.000',
                    icon: Icons.volunteer_activism,
                    iconColor: const Color(0xFF10B981),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 📜 SECCIÓN DE HISTORIAL DE PAGOS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Historial de Ingresos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Lista de transacciones simuladas de ejemplo
                  _buildTransactionItem(
                    petName: 'Max 🐾',
                    date: 'Hoy, 6:15 PM',
                    amount: '\$45.000',
                    duration: '2 horas de cuidado',
                  ),
                  _buildTransactionItem(
                    petName: 'Loki 🐕',
                    date: 'Ayer, 2:30 PM',
                    amount: '\$60.000',
                    duration: '3 horas de cuidado',
                  ),
                  _buildTransactionItem(
                    petName: 'Luna 🐱',
                    date: '15 de Junio, 10:00 AM',
                    amount: '\$45.000',
                    duration: '2 horas de cuidado',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              radius: 18,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String petName,
    required String date,
    required String amount,
    required String duration,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFF3F4F6),
          child: Icon(Icons.arrow_downward, color: Color(0xFF10B981)), // Flecha verde de ingreso
        ),
        title: Text(
          'Cuidado de $petName',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          '$date • $duration',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Text(
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF10B981),
          ),
        ),
      ),
    );
  }
}