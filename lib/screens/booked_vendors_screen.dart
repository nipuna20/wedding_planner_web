import 'package:flutter/material.dart';
import 'package:wedding_planner/widgets/bottom_navbar.dart';
import 'package:wedding_planner/screens/booking_details_screen.dart';
import 'package:wedding_planner/services/booking_service.dart';
import 'package:intl/intl.dart';

class BookedVendorsScreen extends StatefulWidget {
  const BookedVendorsScreen({super.key});

  @override
  State<BookedVendorsScreen> createState() => _BookedVendorsScreenState();
}

class _BookedVendorsScreenState extends State<BookedVendorsScreen> {
  int _currentIndex = 1;
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final bookings = await BookingService().getMyBookings();
      if (mounted) {
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to load bookings. Please try again.';
          _isLoading = false;
        });
      }
      print('Fetch bookings error: $e');
    }
  }

  Future<void> _deleteBooking(String bookingId) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await BookingService().deleteBooking(bookingId);
      if (mounted) {
        setState(() {
          _bookings.removeWhere((booking) => booking['_id'] == bookingId);
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel booking. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Delete booking error: $e');
    }
  }

  Future<void> _updateBooking(
    String bookingId,
    Map<String, dynamic> updates,
  ) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await BookingService().updateBooking(
        bookingId,
        date: updates['date'],
        timeRange: updates['timeRange'] != null
            ? {
                'startTime': updates['timeRange']['startTime'],
                'endTime': updates['timeRange']['endTime'],
              }
            : null,
        address: updates['address'],
      );
      await _fetchBookings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update booking. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Update booking error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Booked Vendors',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (mounted) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBookings,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : _bookings.isEmpty
                    ? const Center(child: Text('No bookings found.'))
                    : ListView.builder(
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) {
                          final booking = _bookings[index];
                          return ListTile(
                            title: Text(booking['vendorName'] ?? 'Vendor'),
                            subtitle: Text(
                              '${DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['date']))} | ${booking['time']?.join(', ') ?? ''}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showEditDialog(booking),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteBooking(booking['_id'].toString()),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingDetailsScreen(
                                    bookingId: booking['_id'].toString(),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
      ),
    );
  }

  void _showEditDialog(dynamic booking) {
    final _dateController = TextEditingController(text: booking['date']);
    final _startTimeController = TextEditingController(
      text: booking['time']?.isNotEmpty == true ? booking['time'][0].split('-')[0] : '',
    );
    final _endTimeController = TextEditingController(
      text: booking['time']?.isNotEmpty == true ? booking['time'][0].split('-')[1] : '',
    );
    final _addressController = TextEditingController(text: booking['address']);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Booking'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.parse(booking['date']),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _startTimeController,
                      decoration: const InputDecoration(labelText: 'Start Time (HH:mm)'),
                      readOnly: true,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: int.parse(_startTimeController.text.split(':')[0]),
                            minute: int.parse(_startTimeController.text.split(':')[1]),
                          ),
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() {
                            _startTimeController.text =
                                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _endTimeController,
                      decoration: const InputDecoration(labelText: 'End Time (HH:mm)'),
                      readOnly: true,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: int.parse(_endTimeController.text.split(':')[0]),
                            minute: int.parse(_endTimeController.text.split(':')[1]),
                          ),
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() {
                            _endTimeController.text =
                                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_dateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a date')),
                      );
                      return;
                    }
                    if (_startTimeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a start time')),
                      );
                      return;
                    }
                    if (_endTimeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select an end time')),
                      );
                      return;
                    }
                    if (_addressController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter an address')),
                      );
                      return;
                    }
                    final updates = <String, dynamic>{
                      'date': _dateController.text,
                      'timeRange': {
                        'startTime': _startTimeController.text,
                        'endTime': _endTimeController.text,
                      },
                      'address': _addressController.text,
                    };
                    Navigator.pop(context);
                    _updateBooking(booking['_id'].toString(), updates);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}