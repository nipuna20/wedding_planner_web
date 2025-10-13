import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wedding_planner/services/booking_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<dynamic>> _bookingsFuture;
  final BookingService _bookingService = BookingService();
  List<String> _clearedNotificationIds = [];

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _bookingService.getMyBookings();
    _loadClearedNotifications();
  }

  // Load cleared notification IDs from SharedPreferences
  Future<void> _loadClearedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _clearedNotificationIds = prefs.getStringList('cleared_notifications') ?? [];
    });
  }

  // Save cleared notification IDs to SharedPreferences
  Future<void> _saveClearedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cleared_notifications', _clearedNotificationIds);
  }

  // Clear all notifications
  Future<void> _clearNotifications() async {
    final bookings = await _bookingsFuture;
    setState(() {
      _clearedNotificationIds = bookings.map((b) => b['_id']?.toString() ?? '').toList();
    });
    await _saveClearedNotifications();
  }

  // Clear a single notification
  Future<void> _clearSingleNotification(String bookingId) async {
    setState(() {
      if (!_clearedNotificationIds.contains(bookingId)) {
        _clearedNotificationIds.add(bookingId);
      }
    });
    await _saveClearedNotifications();
  }

  // Extract service name from the booking data
  String _getServiceName(Map<String, dynamic> booking) {
    try {
      final serviceId = booking['serviceId']?.toString();
      if (serviceId == null) return 'Service';
      
      final vendorId = booking['vendorId'];
      if (vendorId == null) return 'Service';
      
      final serviceDetails = vendorId['serviceDetails'] as List<dynamic>?;
      if (serviceDetails == null || serviceDetails.isEmpty) return 'Service';
      
      for (var service in serviceDetails) {
        if (service['_id']?.toString() == serviceId) {
          return service['serviceName']?.toString() ?? 'Service';
        }
      }
      
      return 'Service';
    } catch (e) {
      return 'Service';
    }
  }

  // Helper to format date strings
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Get notification icon and color based on booking status
  Map<String, dynamic> _getNotificationStyle(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return {
          'icon': Icons.check_circle,
          'color': Colors.green,
          'backgroundColor': Colors.green.withOpacity(0.1),
        };
      case 'rejected':
        return {
          'icon': Icons.cancel,
          'color': Colors.red,
          'backgroundColor': Colors.red.withOpacity(0.1),
        };
      case 'pending':
        return {
          'icon': Icons.access_time,
          'color': Colors.orange,
          'backgroundColor': Colors.orange.withOpacity(0.1),
        };
      default:
        return {
          'icon': Icons.notifications,
          'color': const Color(0xFF00E7AC),
          'backgroundColor': const Color(0xFF00E7AC).withOpacity(0.1),
        };
    }
  }

  // Get notification message based on status
  String _getNotificationMessage(Map<String, dynamic> booking, String serviceName) {
    final status = booking['status']?.toString().toLowerCase() ?? 'unknown';
    final date = _formatDate(booking['date'] ?? '');
    
    switch (status) {
      case 'confirmed':
        return '$serviceName has been confirmed for $date';
      case 'rejected':
        return '$serviceName booking was rejected for $date';
      case 'pending':
        return '$serviceName booking is pending approval for $date';
      default:
        return '$serviceName booking status updated for $date';
    }
  }

  // Get notification description
  String _getNotificationDescription(Map<String, dynamic> booking, String status) {
    final vendorName = booking['vendorId']?['name'] ?? 'Vendor';
    
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Your booking has been confirmed by $vendorName. You can now proceed with your wedding plans. Please check your booking details for more information.';
      case 'rejected':
        return 'Unfortunately, your booking request was declined by $vendorName. You may want to contact them directly or search for alternative vendors.';
      case 'pending':
        return 'Your booking request is waiting for approval from $vendorName. They will respond soon with their confirmation or alternative suggestions.';
      default:
        return 'Your booking status has been updated. Please check your bookings for more details.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: _clearNotifications,
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Booking updates will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          final bookings = snapshot.data!;
          // Filter to show only uncleared bookings with relevant status
          final notificationBookings = bookings.where((booking) {
            final status = booking['status']?.toString().toLowerCase();
            final bookingId = booking['_id']?.toString() ?? '';
            return (status == 'confirmed' || status == 'rejected' || status == 'pending') &&
                   !_clearedNotificationIds.contains(bookingId);
          }).toList();

          // Sort by most recent first (by creation date)
          notificationBookings.sort((a, b) {
            try {
              final dateA = DateTime.parse(a['createdAt'] ?? a['date'] ?? '');
              final dateB = DateTime.parse(b['createdAt'] ?? b['date'] ?? '');
              return dateB.compareTo(dateA);
            } catch (e) {
              return 0;
            }
          });

          if (notificationBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No booking notifications',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notificationBookings.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final booking = notificationBookings[index];
              final status = booking['status']?.toString() ?? 'pending';
              final notificationStyle = _getNotificationStyle(status);
              final bookingId = booking['_id']?.toString() ?? '';
              
              final serviceName = _getServiceName(booking);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: notificationStyle['color'].withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: notificationStyle['backgroundColor'],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            notificationStyle['icon'],
                            color: notificationStyle['color'],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _getNotificationMessage(booking, serviceName),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: notificationStyle['color'],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getNotificationDescription(booking, status),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Time: ${booking['time']?.join(', ') ?? 'Not specified'}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (booking['address'] != null && booking['address'].toString().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        booking['address'].toString(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.business,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      booking['vendorId']?['businessName'] ?? 'Business',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red, size: 20),
                          onPressed: () => _clearSingleNotification(bookingId),
                        ),
                      ],
                    ),
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