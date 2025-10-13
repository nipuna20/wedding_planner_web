import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wedding_planner/services/booking_service.dart';
import 'package:wedding_planner/services/user_service.dart';

class AvailabilityConfig {
  static const int startHour = 8;
  static const int endHour = 17;
  static const int calendarPastYears = 5;
  static const int calendarFutureYears = 5;
}

class AddAvailabilityScreen extends StatefulWidget {
  final String vendorId;

  const AddAvailabilityScreen({super.key, required this.vendorId});

  @override
  State<AddAvailabilityScreen> createState() => _AddAvailabilityScreenState();
}

class _AddAvailabilityScreenState extends State<AddAvailabilityScreen> {
  final Set<DateTime> _selectedDates = {};
  Map<DateTime, List<Map<String, String>>> _bookedTimesByDate = {};
  Map<DateTime, List<Map<String, String>>> _unavailableTimesByDate = {};
  bool isLoading = false;
  String _serviceId = '';
  final BookingService _bookingService = BookingService();

  @override
  void initState() {
    super.initState();
    _fetchVendorServiceId();
    _fetchAndSetBookedAndUnavailableDates();
  }

  Future<void> _fetchVendorServiceId() async {
    try {
      final profile = await UserService.getProfile();
      if (profile?['user']?['serviceDetails']?.isNotEmpty ?? false) {
        if (mounted) {
          setState(() {
            _serviceId = profile!['user']['serviceDetails'][0]['_id'].toString();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No service details found for vendor.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load vendor service details.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error fetching vendor service ID: $e');
    }
  }

  Future<void> _fetchAndSetBookedAndUnavailableDates() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final bookings = await _bookingService.getVendorBookings(widget.vendorId);
      final Map<DateTime, List<Map<String, String>>> tempBookedTimesByDate = {};
      final Map<DateTime, List<Map<String, String>>> tempUnavailableTimesByDate = {};
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
        } else if (booking['bookingType'] == 'availability') {
          tempUnavailableTimesByDate.putIfAbsent(dateOnly, () => []).add(timeRange);
        }
      }

      if (mounted) {
        setState(() {
          _bookedTimesByDate = tempBookedTimesByDate;
          _unavailableTimesByDate = tempUnavailableTimesByDate;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load booked or unavailable dates.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error fetching bookings: $e');
    }
  }

  Future<void> saveAvailability(DateTime date, Map<String, String> timeRange) async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      await _bookingService.createAvailability(
        vendorId: widget.vendorId,
        serviceId: _serviceId,
        date: formattedDate,
        timeRange: timeRange,
        address: 'Vendor Availability',
      );
      await _fetchAndSetBookedAndUnavailableDates();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Availability saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save availability. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error saving availability: $e');
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _showAvailabilityDialog(DateTime date) {
    final dateOnly = DateTime.utc(date.year, date.month, date.day);
    final bookedTimes = _bookedTimesByDate[dateOnly] ?? [];
    final unavailableTimes = _unavailableTimesByDate[dateOnly] ?? [];
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    String _formatTime(TimeOfDay time) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }

    bool _isTimeRangeValid(TimeOfDay start, TimeOfDay end) {
      final startDateTime = DateTime(date.year, date.month, date.day, start.hour, start.minute);
      final endDateTime = DateTime(date.year, date.month, date.day, end.hour, end.minute);
      if (startDateTime.isAfter(endDateTime) || startDateTime.isAtSameMomentAs(endDateTime)) return false;

      final minTime = DateTime(date.year, date.month, date.day, 8, 0);
      final maxTime = DateTime(date.year, date.month, date.day, 17, 0);
      if (startDateTime.isBefore(minTime) || endDateTime.isAfter(maxTime)) return false;

      for (var booked in bookedTimes) {
        if (booked['startTime'] == null || booked['endTime'] == null) continue;
        final bookedStart = DateTime.parse(
            '${date.toIso8601String().split('T')[0]}T${booked['startTime']}:00');
        final bookedEnd = DateTime.parse(
            '${date.toIso8601String().split('T')[0]}T${booked['endTime']}:00');
        if (startDateTime.isBefore(bookedEnd) && bookedStart.isBefore(endDateTime)) {
          return false;
        }
      }

      for (var unavailable in unavailableTimes) {
        if (unavailable['startTime'] == null || unavailable['endTime'] == null) continue;
        final unavailableStart = DateTime.parse(
            '${date.toIso8601String().split('T')[0]}T${unavailable['startTime']}:00');
        final unavailableEnd = DateTime.parse(
            '${date.toIso8601String().split('T')[0]}T${unavailable['endTime']}:00');
        if (startDateTime.isBefore(unavailableEnd) && unavailableStart.isBefore(endDateTime)) {
          return false;
        }
      }

      return true;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Set Unavailable Time for ${date.day}/${date.month}/${date.year}', style: TextStyle(fontSize: screenWidth > 600 ? 20 : 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booked Time Ranges:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    bookedTimes.isEmpty
                        ? const Text('No bookings for this date.')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: bookedTimes
                                .map((time) => Text('• ${time['startTime'] ?? 'N/A'} - ${time['endTime'] ?? 'N/A'}'))
                                .toList(),
                          ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vendor Unavailable Time Ranges:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    unavailableTimes.isEmpty
                        ? const Text('No unavailable times set.')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: unavailableTimes
                                .map((time) => Text('• ${time['startTime'] ?? 'N/A'} - ${time['endTime'] ?? 'N/A'}'))
                                .toList(),
                          ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Unavailable Time Range:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 8, minute: 0),
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );
                        if (selectedTime != null) {
                          setDialogState(() {
                            startTime = selectedTime;
                            if (endTime != null && !_isTimeRangeValid(startTime!, endTime!)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Selected start time conflicts with booked or unavailable times.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          });
                        }
                      },
                      child: Text(startTime == null ? 'Select Start Time' : _formatTime(startTime!)),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 9, minute: 0),
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );
                        if (selectedTime != null) {
                          setDialogState(() {
                            endTime = selectedTime;
                            if (startTime != null && !_isTimeRangeValid(startTime!, endTime!)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Selected end time conflicts with booked or unavailable times.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          });
                        }
                      },
                      child: Text(endTime == null ? 'Select End Time' : _formatTime(endTime!)),
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
                  onPressed: (startTime == null || endTime == null || !_isTimeRangeValid(startTime!, endTime!))
                      ? null
                      : () async {
                          Navigator.pop(context);
                          final timeRange = {
                            'startTime': _formatTime(startTime!),
                            'endTime': _formatTime(endTime!),
                          };
                          await saveAvailability(date, timeRange);
                        },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: (startTime != null && endTime != null && _isTimeRangeValid(startTime!, endTime!))
                          ? const LinearGradient(
                              colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                            )
                          : null,
                      color: (startTime == null || endTime == null || !_isTimeRangeValid(startTime!, endTime!))
                          ? Colors.grey.shade300
                          : null,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Text(
                        'Save Unavailable Time',
                        style: TextStyle(color: Colors.white, fontSize: screenWidth > 600 ? 16 : 14),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final now = DateTime.now();
    final firstDay = DateTime.utc(now.year - AvailabilityConfig.calendarPastYears);
    final lastDay = DateTime.utc(now.year + AvailabilityConfig.calendarFutureYears);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Add Unavailable Time',
          style: TextStyle(color: Colors.black, fontSize: screenWidth > 600 ? 24 : 18),
        ),
        leading: const BackButton(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 32 : 16),
                  padding: EdgeInsets.all(screenWidth > 600 ? 16 : 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: TableCalendar(
                    focusedDay: DateTime.now(),
                    firstDay: firstDay,
                    lastDay: lastDay,
                    calendarFormat: CalendarFormat.month,
                    selectedDayPredicate: (day) => _selectedDates.any(
                      (d) => d.year == day.year && d.month == day.month && d.day == day.day,
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      if (mounted) {
                        setState(() {
                          _selectedDates.contains(selectedDay)
                              ? _selectedDates.remove(selectedDay)
                              : _selectedDates.add(selectedDay);
                        });
                        _showAvailabilityDialog(selectedDay);
                      }
                    },
                    calendarStyle: CalendarStyle(
                      isTodayHighlighted: true,
                      selectedDecoration: const BoxDecoration(shape: BoxShape.circle),
                      selectedTextStyle: const TextStyle(color: Colors.black),
                      outsideDaysVisible: false,
                      markerDecoration: const BoxDecoration(shape: BoxShape.circle),
                      markersMaxCount: 2,
                      cellMargin: const EdgeInsets.all(4),
                      defaultDecoration: const BoxDecoration(shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      disabledDecoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                    ),
                    enabledDayPredicate: (day) {
                      final dateOnly = DateTime.utc(day.year, day.month, day.day);
                      return !_bookedTimesByDate.containsKey(dateOnly) ||
                          _bookedTimesByDate[dateOnly]!.length < 2;
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        final dateOnly = DateTime.utc(date.year, date.month, date.day);
                        List<Widget> markers = [];
                        if (_bookedTimesByDate.containsKey(dateOnly)) {
                          markers.add(
                            Positioned(
                              bottom: 1,
                              left: 1,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        }
                        if (_unavailableTimesByDate.containsKey(dateOnly)) {
                          markers.add(
                            Positioned(
                              bottom: 1,
                              right: 1,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.yellow,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        }
                        return markers.isNotEmpty ? Stack(children: markers) : null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Booked", style: TextStyle(fontSize: screenWidth > 600 ? 16 : 14)),
                    const SizedBox(width: 12),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text("Vendor Unavailable", style: TextStyle(fontSize: screenWidth > 600 ? 16 : 14)),
                    const SizedBox(width: 12),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.all(screenWidth > 600 ? 24 : 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: screenWidth > 600 ? 56 : 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _fetchAndSetBookedAndUnavailableDates(),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Refresh',
                                  style: TextStyle(color: Colors.white, fontSize: screenWidth > 600 ? 18 : 16),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}