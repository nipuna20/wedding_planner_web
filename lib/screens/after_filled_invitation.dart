import 'package:flutter/material.dart';
import 'package:wedding_planner/screens/select_guests_for_invitation_screen.dart';
import 'package:wedding_planner/services/invitation_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class AfterFilledInvitationScreen extends StatefulWidget {
  const AfterFilledInvitationScreen({super.key});

  @override
  State<AfterFilledInvitationScreen> createState() =>
      _AfterFilledInvitationScreenState();
}

class _AfterFilledInvitationScreenState
    extends State<AfterFilledInvitationScreen> {
  Map<String, dynamic>? invitationData;

  @override
  void initState() {
    super.initState();
    _fetchInvitationData();
  }

  Future<void> _fetchInvitationData() async {
    final data = await InvitationService.getInvitationSettings();
    if (data != null && data['success']) {
      setState(() {
        invitationData = data['invitation'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load invitation data')),
      );
    }
  }

  Future<void> _selectGuests() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SelectGuestsForInvitationScreen(),
      ),
    );

    if (result == true) {
      Fluttertoast.showToast(msg: "Invitations sent to selected guests");
    }
  }

  Future<void> _shareInvitationViaEmail() async {
    if (invitationData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitation data not loaded')),
      );
      return;
    }

    // Construct the email body
    String subject =
        'Wedding Invitation - ${invitationData!['brideName']} & ${invitationData!['groomName']}';
    String body = '''
Dear [Recipient's Name],

You are cordially invited to the wedding of ${invitationData!['brideName']} & ${invitationData!['groomName']}!

**Details:**
- **Date:** ${invitationData!['weddingDate']}
- **Time:** ${invitationData!['time']}
- **Venue:** ${invitationData!['venue']}
- **Message:** ${invitationData!['message'] ?? 'No additional message.'}

Please join us to celebrate this special occasion!

Best regards,
[Your Name]

[Attachment: Invitation Image - ${invitationData!['template']}]  // Note: Actual attachment requires file handling
''';

    // Encode the body to handle special characters
    final emailUri = Uri(
      scheme: 'mailto',
      path: '', // Leave blank or specify a recipient email if known
      query: 'subject=$subject&body=${Uri.encodeComponent(body)}',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email client')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Invitation',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          invitationData == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Image.asset(
                    invitationData!['template'] ??
                        'assets/images/template1.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey,
                        child: const Center(
                          child: Text('Image failed to load'),
                        ),
                      );
                    },
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'You Are Invited!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '${invitationData!['brideName']} & ${invitationData!['groomName']}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Wedding Date: ${invitationData!['weddingDate']}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Time: ${invitationData!['time']}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Venue: ${invitationData!['venue']}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          invitationData!['message'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _selectGuests,
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
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                                child: Text(
                                  'Select Guests',
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
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _shareInvitationViaEmail,
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
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                                child: Text(
                                  'Share Invitation',
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
                ],
              ),
    );
  }
}
