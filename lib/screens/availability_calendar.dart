import 'package:flutter/material.dart';
import 'package:wedding_planner/screens/payment_page.dart';
import 'package:wedding_planner/services/booking_service.dart';
import 'select_time_page.dart';

class AvailabilityCalendar extends StatefulWidget {
  final String vendorId;
  final String serviceId;
  final String? packageId;
  final String vendorName;

  const AvailabilityCalendar({
    super.key,
    required this.vendorId,
    required this.serviceId,
    this.packageId,
    required this.vendorName,
  });

  @override
  _AvailabilityCalendarState createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  DateTime currentMonth = DateTime.now();
  Map<DateTime, List<Map<String, String>>> bookedTimesByDate = {};
  Map<DateTime, List<Map<String, String>>> unavailableTimesByDate = {};
  Map<DateTime, int> bookingCountByDate = {};
  Set<DateTime> selectedDates = {};
  bool _isLoading = true;

  final BookingService _bookingService = BookingService();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final String _selectedPaymentType = 'cash';

  @override
  void initState() {
    super.initState();
    _timeController.text = '';
    _fetchAndSetDates();
  }

  Future<void> _fetchAndSetDates() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final bookings = await _bookingService.getVendorBookings(widget.vendorId);
      final Map<DateTime, List<Map<String, String>>> tempBookedTimesByDate = {};
      final Map<DateTime, List<Map<String, String>>> tempUnavailableTimesByDate = {};
      final Map<DateTime, int> tempBookingCountByDate = {};
      for (var booking in bookings) {
        final date = DateTime.tryParse(booking['date'] ?? '');
        if (date == null) continue;
        final dateOnly = DateTime.utc(date.year, date.month, date.day);
        final timeRange = booking['timeRange'] != null
            ? {
                'startTime': booking['timeRange']['startTime']?.toString() ?? '',
                'endTime': booking['timeRange']['endTime']?.toString() ?? ''
              }
            : {'startTime': '', 'endTime': ''};
        if (booking['bookingType'] == 'booking') {
          tempBookedTimesByDate.putIfAbsent(dateOnly, () => []).add(timeRange);
          tempBookingCountByDate[dateOnly] = (tempBookingCountByDate[dateOnly] ?? 0) + 1;
        } else if (booking['bookingType'] == 'availability') {
          tempUnavailableTimesByDate.putIfAbsent(dateOnly, () => []).add(timeRange);
        }
      }

      if (mounted) {
        setState(() {
          bookedTimesByDate = tempBookedTimesByDate;
          unavailableTimesByDate = tempUnavailableTimesByDate;
          bookingCountByDate = tempBookingCountByDate;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load availability. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error fetching bookings: $e');
    }
  }

  void _previousMonth() {
    if (mounted) {
      setState(() {
        currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
      });
    }
  }

  void _nextMonth() {
    if (mounted) {
      setState(() {
        currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Availability',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                              onPressed: _previousMonth,
                            ),
                            Text(
                              _getMonthYearString(currentMonth),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                              onPressed: _nextMonth,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _dayOfWeekHeader('Sun'),
                            _dayOfWeekHeader('Mon'),
                            _dayOfWeekHeader('Tue'),
                            _dayOfWeekHeader('Wed'),
                            _dayOfWeekHeader('Thu'),
                            _dayOfWeekHeader('Fri'),
                            _dayOfWeekHeader('Sat'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCalendarGrid(),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Fully Booked',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Booked',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Vendor Unavailable',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _showBookingDialog,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              disabledBackgroundColor: Colors.grey.shade300,
                            ),
                            child: Ink(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              child: const Center(
                                child: Text(
                                  'Confirm Selection',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _dayOfWeekHeader(String day) {
    return Expanded(
      child: Text(
        day,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstDayWeekday = firstDayOfMonth.weekday % 7;

    final List<Widget> dayWidgets = [];
    for (int i = 0; i < firstDayWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);
      final dateOnly = DateTime.utc(date.year, date.month, date.day);
      final isToday = dateOnly == DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final isSelected = selectedDates.contains(dateOnly);
      final hasBookings = bookedTimesByDate.containsKey(dateOnly);
      final hasVendorUnavailability = unavailableTimesByDate.containsKey(dateOnly);
      final isFullyBooked = bookingCountByDate[dateOnly] != null && bookingCountByDate[dateOnly]! >= 2;

      final dayColor = isFullyBooked
          ? Colors.grey[600]
          : isToday
              ? Colors.teal
              : Colors.black;

      dayWidgets.add(
        GestureDetector(
          onTap: isFullyBooked
              ? null
              : () {
                  if (mounted) {
                    setState(() {
                      if (selectedDates.contains(dateOnly)) {
                        selectedDates.remove(dateOnly);
                      } else {
                        selectedDates.clear();
                        selectedDates.add(dateOnly);
                      }
                    });
                  }
                },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: isSelected && !isFullyBooked
                  ? const LinearGradient(
                      colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected && !isFullyBooked
                  ? null
                  : isFullyBooked
                      ? Colors.grey[400]
                      : (hasVendorUnavailability
                          ? Colors.yellow.shade100
                          : Colors.transparent),
              border: isSelected && !isFullyBooked
                  ? Border.all(color: Colors.blueAccent, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(6),
              boxShadow: isSelected && !isFullyBooked
                  ? [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected && !isFullyBooked ? Colors.white : dayColor,
                    ),
                  ),
                ),
                if (hasBookings)
                  Positioned(
                    bottom: 2,
                    left: 2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (hasVendorUnavailability)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      children: dayWidgets,
    );
  }

  String _getMonthYearString(DateTime date) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showBookingDialog() {
    if (selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an available date'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final selectedDate = selectedDates.first;
    final dateOnly = DateTime.utc(selectedDate.year, selectedDate.month, selectedDate.day);
    final bookedTimes = bookedTimesByDate[dateOnly] ?? [];
    final vendorUnavailableTimes = unavailableTimesByDate[dateOnly] ?? [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Confirm Booking'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selected date:'),
                    const SizedBox(height: 8),
                    Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Address',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        hintText: 'Enter booking address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Time Range',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    TextField(
                      controller: _timeController,
                      readOnly: true,
                      onTap: () async {
                        Navigator.of(context).pop();
                        final selectedTimeRange = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SelectTimePage(
                              bookedTimes: bookedTimes,
                              vendorUnavailableTimes: vendorUnavailableTimes,
                              bookingDate: selectedDate,
                            ),
                          ),
                        );
                        if (selectedTimeRange != null && selectedTimeRange is Map<String, String>) {
                          if (mounted) {
                            setState(() {
                              final startTime = selectedTimeRange['startTime'] ?? '';
                              final endTime = selectedTimeRange['endTime'] ?? '';
                              if (startTime.isNotEmpty && endTime.isNotEmpty) {
                                _timeController.text = '$startTime - $endTime';
                              } else {
                                _timeController.text = '';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid time range selected.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            });
                          }
                          _showBookingDialog();
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'Select Time Range',
                        suffixIcon: Icon(Icons.access_time, color: Colors.teal),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Payment Type: Cash only',
                      style: TextStyle(fontWeight: FontWeight.w500),
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
                    if (_addressController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter an address')),
                      );
                      return;
                    }
                    if (_timeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a time range')),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    _processBooking();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) => Colors.transparent,
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _processBooking() async {
    if (!mounted) return;
    try {
      final selectedDate = selectedDates.first;
      final formattedDate =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      final timeRangeParts = _timeController.text.split(' - ');
      if (timeRangeParts.length != 2 || timeRangeParts[0].isEmpty || timeRangeParts[1].isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid time range format. Please select a valid time range.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      final timeRange = {
        'startTime': timeRangeParts[0],
        'endTime': timeRangeParts[1],
      };

      final result = await _bookingService.createBooking(
        vendorId: widget.vendorId,
        serviceId: widget.serviceId,
        packageId: widget.packageId,
        date: formattedDate,
        timeRange: timeRange,
        address: _addressController.text.trim(),
        paymentType: _selectedPaymentType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          selectedDates.clear();
          _addressController.clear();
          _timeController.text = '';
        });
        await _fetchAndSetDates();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentPage(
              vendorId: widget.vendorId,
              serviceId: widget.serviceId,
              packageId: widget.packageId,
              bookingId: result['booking']['_id'],
              date: formattedDate,
              time: ['${timeRange['startTime']} - ${timeRange['endTime']}'],
              address: _addressController.text.trim(),
              vendorName: widget.vendorName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().contains('At least one time slot is required')
            ? 'Invalid time slot. Please select a valid time range.'
            : 'Failed to create booking. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error creating booking: $e');
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}