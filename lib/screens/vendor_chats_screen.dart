import 'package:flutter/material.dart';
import 'package:wedding_planner/screens/chat_detail_screen.dart';
import 'package:wedding_planner/services/message_service.dart';
import 'package:intl/intl.dart';

class VendorChatsScreen extends StatefulWidget {
  const VendorChatsScreen({super.key});

  @override
  State<VendorChatsScreen> createState() => _VendorChatsScreenState();
}

class _VendorChatsScreenState extends State<VendorChatsScreen> {
  late Future<Map<String, dynamic>?> _customersFuture;

  @override
  void initState() {
    super.initState();
    _customersFuture = MessageService().getChatUsers();
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp).toLocal();
      return DateFormat('MM/dd/yyyy hh:mm a').format(date);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _customersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!['users']!.isEmpty) {
            return Center(child: Text('No messages found.'));
          }

          final customers = snapshot.data!['users']!;
          return ListView.builder(
            itemCount: customers.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final customer = customers[index];
              return _chatTile(customer);
            },
          );
        },
      ),
    );
  }

  Widget _chatTile(Map<String, dynamic> customer) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChatDetailScreen(
                  otherUserId: customer['_id'],
                  otherUserName: customer['name'] ?? 'Customer',
                ),
          ),
        ).then((_) {
          // Refresh the chat list when returning from chat
          setState(() {
            _customersFuture = MessageService().getChatUsers();
          });
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(
                customer['profileImage'] ?? 'assets/images/profilepic.jpg',
                width: 45,
                height: 45,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Image.asset(
                      'assets/images/profilepic.jpg',
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer['name'] ?? 'Unknown Customer',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    customer['lastMessage'] ?? 'No messages yet',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(customer['lastMessageTime']),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (customer['unreadCount'] > 0) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(0xFF007D8C),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${customer['unreadCount']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
