import 'package:flutter/material.dart';
import 'budget_allocation_page.dart';

class ChooseCategoryScreen extends StatefulWidget {
  const ChooseCategoryScreen({super.key});

  @override
  State<ChooseCategoryScreen> createState() => _ChooseCategoryScreenState();
}

class _ChooseCategoryScreenState extends State<ChooseCategoryScreen> {
  int? selectedIndex;

  final List<Map<String, dynamic>> _vendorCategories = [
    {'label': 'Decoration', 'image': 'assets/images/decoration.png'},
    {'label': 'Photography', 'image': 'assets/images/photography.png'},
    {'label': 'Beautician', 'image': 'assets/images/beautician.png'},
    {'label': 'Wedding Hall', 'image': 'assets/images/wedding_hall.png'},
    {'label': 'Wedding Cars', 'image': 'assets/images/wedding_cars.png'},
    {
      'label': 'Invitation Cards',
      'image': 'assets/images/invitation_cards.png',
    },
    {'label': 'Catering', 'image': 'assets/images/catering.png'},
    {'label': 'Gift Items', 'image': 'assets/images/gift_items.png'},
    {'label': 'Sweets & Cakes', 'image': 'assets/images/sweets_cakes.png'},
    {'label': 'Garland', 'image': 'assets/images/garland.png'},
    {'label': 'Iyer', 'image': 'assets/images/iyer.png'},
    {
      'label': 'Mangala Vathiyam',
      'image': 'assets/images/mangala_vathiyam.png',
    },
    {'label': 'Outdoor Setup', 'image': 'assets/images/outdoor_setup.png'},
    {'label': 'DJ', 'image': 'assets/images/dj.png'},
    {'label': 'Kolam', 'image': 'assets/images/kolam.png'},
    {'label': 'Mehndi Artist', 'image': 'assets/images/mehndi_artist.png'},
    {
      'label': 'Live Music Troupe',
      'image': 'assets/images/live_music_troupe.png',
    },
    {
      'label': 'Jewellery & Accessories',
      'image': 'assets/images/jewellery_accessories.png',
    },
    {'label': 'Wedding Attire', 'image': 'assets/images/wedding_attire.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choose Category",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _vendorCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  bool isSelected = index == selectedIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color(0xFF00B8E4)
                                  : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            _vendorCategories[index]['image'],
                            width: 40,
                            height: 40,
                            color: isSelected ? const Color(0xFF00B8E4) : null,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _vendorCategories[index]['label'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                              color:
                                  isSelected
                                      ? const Color(0xFF00B8E4)
                                      : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedIndex != null) {
                    String selectedCategory =
                        _vendorCategories[selectedIndex!]['label'];
                    String categoryImage =
                        _vendorCategories[selectedIndex!]['image'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BudgetAllocationPage(
                              selectedCategory: selectedCategory,
                              categoryImage: categoryImage,
                            ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a category first'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient:
                        selectedIndex != null
                            ? const LinearGradient(
                              colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                            )
                            : null,
                    color: selectedIndex == null ? Colors.grey[300] : null,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text(
                      'Select',
                      style: TextStyle(
                        color:
                            selectedIndex != null
                                ? Colors.white
                                : Colors.grey[600],
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
