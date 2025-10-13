import 'package:flutter/material.dart';
import 'package:wedding_planner/screens/after_filled_invitation.dart';
import 'package:wedding_planner/services/invitation_service.dart';

class FillInvitationDetailsScreen extends StatefulWidget {
  final String selectedTemplate;
  final DateTime? weddingDate;
  final int? sendBeforeDays;

  const FillInvitationDetailsScreen({
    super.key,
    required this.selectedTemplate,
    this.weddingDate,
    this.sendBeforeDays,
  });

  @override
  State<FillInvitationDetailsScreen> createState() =>
      _FillInvitationDetailsScreenState();
}

class _FillInvitationDetailsScreenState
    extends State<FillInvitationDetailsScreen> {
  final _brideNameController = TextEditingController();
  final _groomNameController = TextEditingController();
  final _weddingDateController = TextEditingController();
  final _timeController = TextEditingController();
  final _venueController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.weddingDate != null) {
      _weddingDateController.text =
          "${widget.weddingDate!.day}/${widget.weddingDate!.month}/${widget.weddingDate!.year}";
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDate: widget.weddingDate ?? DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _weddingDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _saveInvitation() async {
    if (_brideNameController.text.isEmpty ||
        _groomNameController.text.isEmpty ||
        _weddingDateController.text.isEmpty ||
        _timeController.text.isEmpty ||
        _venueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    bool success = await InvitationService.saveInvitationSettings(
      weddingDate: _weddingDateController.text,
      sendBeforeDays: widget.sendBeforeDays ?? 7,
      brideName: _brideNameController.text,
      groomName: _groomNameController.text,
      time: _timeController.text,
      venue: _venueController.text,
      message: _messageController.text,
      template: widget.selectedTemplate,
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AfterFilledInvitationScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save invitation details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fill details of invitation',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Bride Name *'),
            _buildInputField(
              controller: _brideNameController,
              hint: 'Bride Name',
            ),
            const SizedBox(height: 16),

            _buildLabel('Groom Name *'),
            _buildInputField(
              controller: _groomNameController,
              hint: 'Groom Name',
            ),
            const SizedBox(height: 16),

            _buildLabel('Wedding Date *'),
            _buildInputField(
              controller: _weddingDateController,
              hint: 'Wedding Date',
              readOnly: true,
              suffixIcon: Icons.calendar_today,
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),

            _buildLabel('Time *'),
            _buildInputField(
              controller: _timeController,
              hint: 'Time',
              readOnly: true,
              suffixIcon: Icons.access_time,
              onTap: _selectTime,
            ),
            const SizedBox(height: 16),

            _buildLabel('Wedding Venue *'),
            _buildInputField(
              controller: _venueController,
              hint: 'Wedding Venue',
              suffixIcon: Icons.location_on,
            ),
            const SizedBox(height: 16),

            _buildLabel('Your Message'),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveInvitation,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    IconData? suffixIcon,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon:
            suffixIcon != null ? Icon(suffixIcon, color: Colors.teal) : null,
        border: const UnderlineInputBorder(),
      ),
    );
  }
}
