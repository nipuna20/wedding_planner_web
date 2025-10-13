import 'package:flutter/material.dart';

class SelectTimePage extends StatefulWidget {
  final List<Map<String, String>> bookedTimes;
  final List<Map<String, String>> vendorUnavailableTimes;
  final DateTime bookingDate;

  const SelectTimePage({
    super.key,
    required this.bookedTimes,
    required this.vendorUnavailableTimes,
    required this.bookingDate,
  });

  @override
  State<SelectTimePage> createState() => _SelectTimePageState();
}

class _SelectTimePageState extends State<SelectTimePage> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late List<Map<String, String>> _cleanedBookedTimes;
  late List<Map<String, String>> _cleanedVendorUnavailableTimes;

  @override
  void initState() {
    super.initState();
    print('DEBUG: initState - Original Booked Times: ${widget.bookedTimes}');
    print('DEBUG: initState - Original Vendor Unavailable Times: ${widget.vendorUnavailableTimes}');
    _cleanedBookedTimes = _cleanTimeList(widget.bookedTimes);
    _cleanedVendorUnavailableTimes = _cleanTimeList(widget.vendorUnavailableTimes);
    print('DEBUG: initState - Cleaned Booked Times: $_cleanedBookedTimes');
    print('DEBUG: initState - Cleaned Vendor Unavailable Times: $_cleanedVendorUnavailableTimes');
    if (widget.bookedTimes.length != _cleanedBookedTimes.length ||
        widget.vendorUnavailableTimes.length != _cleanedVendorUnavailableTimes.length) {
      print('DEBUG: initState - Invalid time entries were filtered out');
    }
  }

  // Convert TimeOfDay to string format (12-hour with AM/PM for display, 24-hour for internal use)
  String _formatTime(TimeOfDay time, {bool use24Hour = false}) {
    if (use24Hour) {
      final formatted = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      print('DEBUG: _formatTime - 24-hour Formatted Time: $formatted');
      return formatted;
    } else {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      final formatted = '$hour:${time.minute.toString().padLeft(2, '0')} $period';
      print('DEBUG: _formatTime - 12-hour Formatted Time: $formatted');
      return formatted;
    }
  }

  // Validate time string format (HH:mm)
  bool _isValidTimeString(String? time) {
    if (time == null) {
      print('DEBUG: _isValidTimeString - Time is null');
      return false;
    }
    final regExp = RegExp(r'^\d{2}:\d{2}$');
    final isValid = regExp.hasMatch(time);
    print('DEBUG: _isValidTimeString - Time: $time, Valid: $isValid');
    return isValid;
  }

  // Clean time list by filtering out invalid entries
  List<Map<String, String>> _cleanTimeList(List<Map<String, String>> times) {
    print('DEBUG: _cleanTimeList - Processing times: $times');
    final cleaned = times.where((time) {
      final start = time['startTime'];
      final end = time['endTime'];
      final isValid = _isValidTimeString(start) && _isValidTimeString(end);
      if (!isValid) {
        print('DEBUG: _cleanTimeList - Skipping invalid time: start=$start, end=$end');
      }
      return isValid;
    }).toList();
    print('DEBUG: _cleanTimeList - Cleaned times: $cleaned');
    return cleaned;
  }

  // Check if selected time range overlaps with booked or unavailable times
  bool _isTimeRangeValid(TimeOfDay start, TimeOfDay end) {
    print('DEBUG: _isTimeRangeValid - Checking start: ${start.hour}:${start.minute}, end: ${end.hour}:${end.minute}');
    final startDateTime = DateTime(
      widget.bookingDate.year,
      widget.bookingDate.month,
      widget.bookingDate.day,
      start.hour,
      start.minute,
    );
    final endDateTime = DateTime(
      widget.bookingDate.year,
      widget.bookingDate.month,
      widget.bookingDate.day,
      end.hour,
      end.minute,
    );
    print('DEBUG: _isTimeRangeValid - Start DateTime: $startDateTime, End DateTime: $endDateTime');

    if (startDateTime.isAfter(endDateTime) || startDateTime.isAtSameMomentAs(endDateTime)) {
      print('DEBUG: _isTimeRangeValid - Invalid: Start time is after or same as end time');
      return false;
    }

    final minTime = DateTime(
      widget.bookingDate.year,
      widget.bookingDate.month,
      widget.bookingDate.day,
      1,
      0,
    );
    final maxTime = DateTime(
      widget.bookingDate.year,
      widget.bookingDate.month,
      widget.bookingDate.day,
      23,
      0,
    );
    if (startDateTime.isBefore(minTime) || endDateTime.isAfter(maxTime)) {
      print('DEBUG: _isTimeRangeValid - Invalid: Outside allowed range (7:00-23:00)');
      return false;
    }

    for (var booked in _cleanedBookedTimes) {
      final startTime = booked['startTime']!;
      final endTime = booked['endTime']!;
      print('DEBUG: _isTimeRangeValid - Checking booked time: $startTime - $endTime');
      try {
        final bookedStart = DateTime.parse(
            '${widget.bookingDate.toIso8601String().split('T')[0]}T$startTime:00');
        final bookedEnd = DateTime.parse(
            '${widget.bookingDate.toIso8601String().split('T')[0]}T$endTime:00');
        print('DEBUG: _isTimeRangeValid - Parsed booked start: $bookedStart, end: $bookedEnd');
        if (startDateTime.isBefore(bookedEnd) && bookedStart.isBefore(endDateTime)) {
          print('DEBUG: _isTimeRangeValid - Conflict with booked time: $startTime - $endTime');
          return false;
        }
      } catch (e) {
        print('DEBUG: _isTimeRangeValid - Error parsing booked time: $startTime - $endTime, $e');
        continue;
      }
    }

    for (var unavailable in _cleanedVendorUnavailableTimes) {
      final startTime = unavailable['startTime']!;
      final endTime = unavailable['endTime']!;
      print('DEBUG: _isTimeRangeValid - Checking unavailable time: $startTime - $endTime');
      try {
        final unavailableStart = DateTime.parse(
            '${widget.bookingDate.toIso8601String().split('T')[0]}T$startTime:00');
        final unavailableEnd = DateTime.parse(
            '${widget.bookingDate.toIso8601String().split('T')[0]}T$endTime:00');
        print('DEBUG: _isTimeRangeValid - Parsed unavailable start: $unavailableStart, end: $unavailableEnd');
        if (startDateTime.isBefore(unavailableEnd) && unavailableStart.isBefore(endDateTime)) {
          print('DEBUG: _isTimeRangeValid - Conflict with unavailable time: $startTime - $endTime');
          return false;
        }
      } catch (e) {
        print('DEBUG: _isTimeRangeValid - Error parsing unavailable time: $startTime - $endTime, $e');
        continue;
      }
    }

    print('DEBUG: _isTimeRangeValid - Time range is valid');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _startTime != null && _endTime != null && _isTimeRangeValid(_startTime!, _endTime!);
    print('DEBUG: build - isValid: $isValid, startTime: $_startTime, endTime: $_endTime');
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
          'Select Time Range',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose a time range for your booking (7:00 AM - 11:00 PM).',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Note: Ensure the time range does not overlap with booked or unavailable times.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            if (_cleanedBookedTimes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booked Times:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  ..._cleanedBookedTimes.map((time) {
                    // Convert booked times to 12-hour format for display
                    final startParts = time['startTime']!.split(':');
                    final endParts = time['endTime']!.split(':');
                    final startTime = TimeOfDay(
                      hour: int.parse(startParts[0]),
                      minute: int.parse(startParts[1]),
                    );
                    final endTime = TimeOfDay(
                      hour: int.parse(endParts[0]),
                      minute: int.parse(endParts[1]),
                    );
                    return Text(
                      '• ${_formatTime(startTime)} - ${_formatTime(endTime)}',
                      style: const TextStyle(color: Colors.red),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            if (_cleanedVendorUnavailableTimes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vendor Unavailable Times:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  ..._cleanedVendorUnavailableTimes.map((time) {
                    // Convert unavailable times to 12-hour format for display
                    final startParts = time['startTime']!.split(':');
                    final endParts = time['endTime']!.split(':');
                    final startTime = TimeOfDay(
                      hour: int.parse(startParts[0]),
                      minute: int.parse(startParts[1]),
                    );
                    final endTime = TimeOfDay(
                      hour: int.parse(endParts[0]),
                      minute: int.parse(endParts[1]),
                    );
                    return Text(
                      '• ${_formatTime(startTime)} - ${_formatTime(endTime)}',
                      style: const TextStyle(color: Colors.yellow),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ElevatedButton(
              onPressed: () async {
                print('DEBUG: Start time picker opened');
                final selectedTime = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 7, minute: 0),
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    );
                  },
                );
                if (selectedTime != null) {
                  print('DEBUG: Start time selected: ${selectedTime.hour}:${selectedTime.minute}');
                  setState(() {
                    _startTime = selectedTime;
                    if (_endTime != null && !_isTimeRangeValid(_startTime!, _endTime!)) {
                      print('DEBUG: Start time conflicts with booked/unavailable times');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selected start time conflicts with booked or unavailable times.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  });
                } else {
                  print('DEBUG: Start time picker cancelled');
                }
              },
              child: Text(_startTime == null ? 'Select Start Time' : _formatTime(_startTime!)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                print('DEBUG: End time picker opened');
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
                  print('DEBUG: End time selected: ${selectedTime.hour}:${selectedTime.minute}');
                  setState(() {
                    _endTime = selectedTime;
                    if (_startTime != null && !_isTimeRangeValid(_startTime!, _endTime!)) {
                      print('DEBUG: End time conflicts with booked/unavailable times');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Choose a time range for your booking (7:00 AM - 11:00 PM).'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  });
                } else {
                  print('DEBUG: End time picker cancelled');
                }
              },
              child: Text(_endTime == null ? 'Select End Time' : _formatTime(_endTime!)),
            ),
            const SizedBox(height: 16),
            Tooltip(
              message: isValid
                  ? ''
                  : 'Please select a valid time range that does not overlap with booked or unavailable times.',
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isValid
                      ? () {
                          final result = {
                            'startTime': _formatTime(_startTime!, use24Hour: true),
                            'endTime': _formatTime(_endTime!, use24Hour: true),
                          };
                          print('DEBUG: Confirm button pressed - Returning: $result');
                          Navigator.pop(context, result);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: isValid
                          ? const LinearGradient(
                              colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                            )
                          : null,
                      color: isValid ? null : Colors.grey.shade300,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Center(
                      child: Text(
                        'Confirm Time Range',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isValid ? Colors.white : Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}