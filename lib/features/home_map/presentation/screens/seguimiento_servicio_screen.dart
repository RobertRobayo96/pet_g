import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeguimientoServicioScreen extends StatefulWidget {
  final String petName;
  final String cuidadorName;

  const SeguimientoServicioScreen({
    super.key, 
    required this.petName, 
    required this.cuidadorName
  });

  @override
  State<SeguimientoServicioScreen> createState() => _SeguimientoServicioScreenState();
}

class _SeguimientoServicioScreenState extends State<SeguimientoServicioScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _enviarMensaje() async {
    if (_messageController.text.trim().isEmpty) return;

    final texto = _messageController.text.trim();
    _messageController.clear();

    // Guardamos el mensaje en una subcolección dentro de la solicitud activa
    await FirebaseFirestore.instance
        .collection('solicitudes')
        .doc('active_service')
        .collection('chats')
        .add({
      'sender': 'owner',
      'text': texto,
      'timestamp': FieldValue.serverTimestamp(),
      'isImage': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.cuidadorName, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Paseando a ${widget.petName} 🐾', style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 📲 1. LISTA DE MENSAJES EN TIEMPO REAL
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('solicitudes')
                  .doc('active_service')
                  .collection('chats')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('¡Chat iniciado! Pídele fotos de ${widget.petName} al cuidador.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true, // Para que los mensajes nuevos aparezcan abajo
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data['sender'] == 'owner';
                    final text = data['text'] ?? '';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF1E3A8A) : Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 📥 2. BARRA DE ENTRADA DE TEXTO
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Botón multimedia (Para simular el envío de fotos/videos en el MVP)
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Color(0xFF1E3A8A)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Simulación de cámara: Almacenamiento en Firebase Storage (Próxima versión)')),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1E3A8A),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: _enviarMensaje,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}