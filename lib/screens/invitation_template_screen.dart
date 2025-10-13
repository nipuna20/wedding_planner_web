import 'package:flutter/material.dart';
import 'package:wedding_planner/screens/fill_invitation_details_screen.dart';

class InvitationTemplateScreen extends StatefulWidget {
  final DateTime? weddingDate;
  final int? sendBeforeDays;

  const InvitationTemplateScreen({
    super.key,
    this.weddingDate,
    this.sendBeforeDays,
  });

  @override
  State<InvitationTemplateScreen> createState() =>
      _InvitationTemplateScreenState();
}

class _InvitationTemplateScreenState extends State<InvitationTemplateScreen> {
  int selectedIndex = 0;

  final List<String> templates = [
    'assets/images/template1.jpg',
    'assets/images/template2.jpg',
    'assets/images/template3.jpg',
    'assets/images/template4.jpg',
    'assets/images/template5.jpg',
    'assets/images/template6.jpg',
    'assets/images/template7.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Invitation Template',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  templates[selectedIndex],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey,
                      child: const Center(child: Text('Image failed to load')),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => setState(() => selectedIndex = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding:
                        selectedIndex == index
                            ? const EdgeInsets.all(2)
                            : EdgeInsets.zero,
                    decoration: BoxDecoration(
                      border:
                          selectedIndex == index
                              ? Border.all(color: Colors.teal, width: 2)
                              : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        templates[index],
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey,
                            child: const Center(child: Text('Error')),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => FillInvitationDetailsScreen(
                            selectedTemplate: templates[selectedIndex],
                            weddingDate: widget.weddingDate,
                            sendBeforeDays: widget.sendBeforeDays,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Ink(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: const Center(
                    child: Text(
                      'Choose',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
