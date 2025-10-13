import 'package:flutter/material.dart';
import 'package:wedding_planner/screens/vendor_chats_screen.dart';
import 'package:wedding_planner/screens/vendor_dashboard_screen.dart';
import 'package:wedding_planner/screens/vendor_order_page.dart';
import 'package:wedding_planner/screens/vendor_profile_screen.dart';
import 'package:wedding_planner/services/message_service.dart';

class VendorNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const VendorNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<VendorNavBar> createState() => _VendorNavBarState();
}

class _VendorNavBarState extends State<VendorNavBar> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
  }

  void _fetchUnreadCount() async {
    final result = await MessageService().getChatUsers();
    if (result != null && result['totalUnread'] != null) {
      setState(() {
        _unreadCount = result['totalUnread'] as int;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Color(0xFF007D8C),
        unselectedItemColor: Colors.grey,
        currentIndex: widget.currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VendorDashboardScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VendorOrderPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VendorChatsScreen()),
            ).then((_) {
              // Refresh unread count when returning from chat screen
              _fetchUnreadCount();
            });
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VendorProfileScreen()),
            );
          } else {
            widget.onTap(index);
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.chat),
                if (_unreadCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color(0xFF007D8C),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_unreadCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
