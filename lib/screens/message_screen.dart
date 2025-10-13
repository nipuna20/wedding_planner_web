import 'package:flutter/material.dart';
import 'package:wedding_planner/screens/chat_detail_screen.dart';
import 'package:wedding_planner/services/message_service.dart';
import 'package:intl/intl.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late Future<Map<String, dynamic>?> _vendorsFuture;

  @override
  void initState() {
    super.initState();
    _vendorsFuture = MessageService().getChatUsers();
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
      appBar: AppBar(
        title: Text('Messages'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _vendorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!['users']!.isEmpty) {
            return Center(child: Text('No messages found.'));
          }

          final vendors = snapshot.data!['users']!;
          return ListView.builder(
            itemCount: vendors.length,
            padding: EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final vendor = vendors[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ChatDetailScreen(
                              otherUserId: vendor['_id'],
                              otherUserName: vendor['name'] ?? 'Vendor',
                            ),
                      ),
                    ).then((_) {
                      // Refresh the message list when returning from chat
                      setState(() {
                        _vendorsFuture = MessageService().getChatUsers();
                      });
                    });
                  },
                  leading: CircleAvatar(
                    backgroundImage:
                        vendor['profileImage'] != null
                            ? NetworkImage(vendor['profileImage'])
                            : AssetImage('assets/images/vender.png')
                                as ImageProvider,
                  ),
                  title: Text(vendor['name'] ?? 'Unknown Vendor'),
                  subtitle: Text(vendor['lastMessage'] ?? 'No messages yet'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatTime(vendor['lastMessageTime'])),
                      if (vendor['unreadCount'] > 0) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Color(0xFF007D8C),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${vendor['unreadCount']}',
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
