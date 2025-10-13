import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wedding_planner/config/api_config.dart';

class BookingService {
  static final String _baseUrl = '${ApiConfig.baseUrl}/bookings';

  // Function to create a booking
  Future<Map<String, dynamic>> createBooking({
    required String vendorId,
    required String serviceId,
    String? packageId,
    required String date,
    required Map<String, String> timeRange,
    required String address,
    String paymentType = 'cash',
    String bookingType = 'booking',
  }) async {
    try {
      final token = await ApiConfig.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      if (timeRange['startTime'] == null || timeRange['endTime'] == null) {
        throw Exception('Invalid time range provided');
      }

      final time = ['${timeRange['startTime']}-${timeRange['endTime']}'];

      final body = jsonEncode({
        'vendorId': vendorId,
        'serviceId': serviceId,
        if (packageId != null) 'packageId': packageId,
        'date': date,
        'time': time,
        'address': address,
        'paymentType': paymentType,
        'bookingType': bookingType,
      });

      print('Request body: $body');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: await ApiConfig.getAuthHeaders(),
        body: body,
      );

      print('Create booking response: ${response.statusCode} ${response.body}');
      final responseData = ApiConfig.handleResponse(response);
      if (responseData != null) {
        return {'success': true, 'booking': responseData['booking']};
      } else {
        throw Exception('Failed to create booking');
      }
    } catch (e) {
      print('Error creating booking: $e');
      throw Exception('Error creating booking: $e');
    }
  }

  // Function to create or update vendor availability
  Future<Map<String, dynamic>> createAvailability({
    required String vendorId,
    required String serviceId,
    required String date,
    required Map<String, String> timeRange,
    required String address,
  }) async {
    return createBooking(
      vendorId: vendorId,
      serviceId: serviceId,
      date: date,
      timeRange: timeRange,
      address: address,
      bookingType: 'availability',
    );
  }

  // Function to get bookings for the current user
  Future<List<dynamic>> getMyBookings() async {
    try {
      final token = await ApiConfig.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/my'),
        headers: await ApiConfig.getAuthHeaders(),
      );

      print('Get bookings response: ${response.statusCode} ${response.body}');
      final responseData = ApiConfig.handleResponse(response);
      if (responseData != null && responseData['success']) {
        return responseData['bookings'];
      } else {
        throw Exception('Failed to fetch bookings');
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      throw Exception('Error fetching bookings: $e');
    }
  }

  // Function to get all bookings and availability for a specific vendor
  Future<List<dynamic>> getVendorBookings(String vendorId) async {
    try {
      final token = await ApiConfig.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$_baseUrl?userId=$vendorId&role=vendor');
      final response = await http.get(
        uri,
        headers: await ApiConfig.getAuthHeaders(),
      );

      print('Get vendor bookings response: ${response.statusCode} ${response.body}');
      final responseData = ApiConfig.handleResponse(response);
      if (responseData != null && responseData['success']) {
        return responseData['bookings'];
      } else {
        throw Exception('Failed to fetch vendor bookings');
      }
    } catch (e) {
      print('Error fetching vendor bookings: $e');
      throw Exception('Error fetching vendor bookings: $e');
    }
  }

  // Function to get booking by ID
  Future<Map<String, dynamic>> getBookingById(String bookingId) async {
    try {
      final token = await ApiConfig.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/$bookingId'),
        headers: await ApiConfig.getAuthHeaders(),
      );

      print('Get booking by ID response: ${response.statusCode} ${response.body}');
      final responseData = ApiConfig.handleResponse(response);
      if (responseData != null && responseData['success']) {
        return responseData['booking'];
      } else {
        throw Exception('Failed to fetch booking details');
      }
    } catch (e) {
      print('Error fetching booking details: $e');
      throw Exception('Error fetching booking details: $e');
    }
  }

  // Function to update a booking
  Future<Map<String, dynamic>> updateBooking(
    String bookingId, {
    String? date,
    Map<String, String>? timeRange,
    String? address,
    String? paymentType,
  }) async {
    try {
      final token = await ApiConfig.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final time = timeRange != null && timeRange['startTime'] != null && timeRange['endTime'] != null
          ? ['${timeRange['startTime']}-${timeRange['endTime']}']
          : null;

      final body = jsonEncode({
        if (date != null) 'date': date,
        if (time != null) 'time': time,
        if (address != null) 'address': address,
        if (paymentType != null) 'paymentType': paymentType,
      });

      final response = await http.put(
        Uri.parse('$_baseUrl/$bookingId'),
        headers: await ApiConfig.getAuthHeaders(),
        body: body,
      );

      print('Update booking response: ${response.statusCode} ${response.body}');
      final responseData = ApiConfig.handleResponse(response);
      if (responseData != null && responseData['success']) {
        return {'success': true, 'booking': responseData['booking']};
      } else {
        throw Exception('Failed to update booking');
      }
    } catch (e) {
      print('Error updating booking: $e');
      throw Exception('Error updating booking: $e');
    }
  }

  // Function to update booking payment status
  Future<void> updateBookingStatus(
    String bookingId, {
    required String status,
  }) async {
    try {
      final token = await ApiConfig.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final body = jsonEncode({'status': status});

      final response = await http.put(
        Uri.parse('$_baseUrl/$bookingId/status'),
        headers: await ApiConfig.getAuthHeaders(),
        body: body,
      );

      print('Update booking status response: ${response.statusCode} ${response.body}');
      final responseData = ApiConfig.handleResponse(response);
      if (responseData != null && responseData['success']) {
        return;
      } else {
        throw Exception('Failed to update booking status');
      }
    } catch (e) {
      print('Error updating booking status: $e');
      throw Exception('Error updating booking status: $e');
    }
  }

  // Function to confirm a booking
  Future<void> confirmBooking(String bookingId) async {
    try {
      final token = await ApiConfig.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/$bookingId/confirm'),
        headers: await ApiConfig.getAuthHeaders(),
      );

      print('Confirm booking response: ${response.statusCode} ${response.body}');
      final responseData = ApiConfig.handleResponse(response);
      if (responseData != null && responseData['success']) {
        return;
      } else {
        throw Exception('Failed to confirm booking');
      }
    } catch (e) {
      print('Error confirming booking: $e');
      throw Exception('Error confirming booking: $e');
    }
  }

  // Function to reject a booking
  Future<void> rejectBooking(String bookingId) async {
    try {
      final token = await ApiConfig.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/$bookingId/reject'),
        headers: await ApiConfig.getAuthHeaders(),
      );

      print('Reject booking response: ${response.statusCode} ${response.body}');
      final responseData = ApiConfig.handleResponse(response);
      if (responseData != null && responseData['success']) {
        return;
      } else {
        throw Exception('Failed to reject booking');
      }
    } catch (e) {
      print('Error rejecting booking: $e');
      throw Exception('Error rejecting booking: $e');
    }
  }

  // Function to delete a booking or availability
  Future<void> deleteBooking(String bookingId) async {
    try {
      final token = await ApiConfig.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/$bookingId'),
        headers: await ApiConfig.getAuthHeaders(),
      );

      print('Delete booking response: ${response.statusCode} ${response.body}');
      final responseData = ApiConfig.handleResponse(response);
      if (responseData != null && responseData['success']) {
        return;
      } else {
        throw Exception('Failed to delete booking');
      }
    } catch (e) {
      print('Error deleting booking: $e');
      throw Exception('Error deleting booking: $e');
    }
  }
}