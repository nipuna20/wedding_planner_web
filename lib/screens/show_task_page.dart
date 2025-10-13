import 'package:flutter/material.dart';
import 'package:wedding_planner/screens/checklist_screen.dart';
import 'package:wedding_planner/services/user_service.dart';

class ShowTaskPage extends StatefulWidget {
  @override
  _ShowTaskPageState createState() => _ShowTaskPageState();
}

class _ShowTaskPageState extends State<ShowTaskPage> {
  bool _isBasicsExpanded = false;
  bool _isRestaurant1Expanded = false;
  bool _isRestaurant2Expanded = false;
  bool _isRestaurant3Expanded = false;
  bool _isRestaurant4Expanded = false;
  List<Map<String, dynamic>> tasks = [];
  int completedTasks = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedTasks = await UserService.getTasks();
      setState(() {
        tasks = fetchedTasks;
        isLoading = false;
        _updateCompletedTasksCount();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load tasks: $e')));
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateCompletedTasksCount() {
    setState(() {
      completedTasks =
          tasks
              .where(
                (task) =>
                    task['completed'] == true || task['isCompleted'] == true,
              )
              .length;
    });
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Completed Tasks',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              Text(
                '$completedTasks/${tasks.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: tasks.isEmpty ? 0.0 : completedTasks / tasks.length,
              backgroundColor: Colors.grey,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tasks.isEmpty
                ? '0%'
                : '${((completedTasks / tasks.length) * 100).round()}% Complete',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Check List',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text(
                    'Start',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Before 1 year - 6 months',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  ExpansionTile(
                    title: const Text(
                      'Go to You  Basics Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.teal),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CheckListScreen(),
                          ),
                        ).then((_) => _fetchTasks());
                      },
                    ),
                    onExpansionChanged: (value) {
                      setState(() {
                        _isBasicsExpanded = value;
                      });
                    },
                    children: _isBasicsExpanded
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                'Tasks 0/${tasks.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ]
                        : [],
                  ),
                  const Text(
                    'Select Main Vendors',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Before 1 year - 6 months',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  ExpansionTile(
                    title: const Text(
                      'Go to Decoration Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.teal),
                    onExpansionChanged: (value) {
                      setState(() {
                        _isRestaurant1Expanded = value;
                      });
                    },
                    children: _isRestaurant1Expanded
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                'Tasks 0/${tasks.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ]
                        : [],
                  ),
                  ExpansionTile(
                    title: const Text(
                      'Go to Photography Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.teal),
                    onExpansionChanged: (value) {
                      setState(() {
                        _isRestaurant2Expanded = value;
                      });
                    },
                    children: _isRestaurant2Expanded
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                'Tasks 0/${tasks.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ]
                        : [],
                  ),
                  ExpansionTile(
                    title: const Text(
                      'Go to Beautician Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.teal),
                    onExpansionChanged: (value) {
                      setState(() {
                        _isRestaurant3Expanded = value;
                      });
                    },
                    children: _isRestaurant3Expanded
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                'Tasks 0/${tasks.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ]
                        : [],
                  ),
                  ExpansionTile(
                    title: const Text(
                      'Go to Wedding Hall Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.teal),
                    onExpansionChanged: (value) {
                      setState(() {
                        _isRestaurant4Expanded = value;
                      });
                    },
                    children: _isRestaurant4Expanded
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                'Tasks 0/${tasks.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ]
                        : [],
                  ),
                  ExpansionTile(
                    title: const Text(
                      'Go to Wedding Car Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.teal),
                    onExpansionChanged: (value) {
                      setState(() {
                        _isRestaurant4Expanded = value;
                      });
                    },
                    children: _isRestaurant4Expanded
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                'Tasks 0/${tasks.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ]
                        : [],
                  ),
                  ExpansionTile(
                    title: const Text(
                      'Go to Catering Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.teal),
                    onExpansionChanged: (value) {
                      setState(() {
                        _isRestaurant4Expanded = value;
                      });
                    },
                    children: _isRestaurant4Expanded
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                'Tasks 0/${tasks.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ]
                        : [],
                  ),
                  ExpansionTile(
                    title: const Text(
                      'Go to Gift Item Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.teal),
                    onExpansionChanged: (value) {
                      setState(() {
                        _isRestaurant4Expanded = value;
                      });
                    },
                    children: _isRestaurant4Expanded
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                'Tasks 0/${tasks.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ]
                        : [],
                  ),
                  ExpansionTile(
                    title: const Text(
                      'Go to Sweet & Cake Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.teal),
                    onExpansionChanged: (value) {
                      setState(() {
                        _isRestaurant4Expanded = value;
                      });
                    },
                    children: _isRestaurant4Expanded
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                'Tasks 0/${tasks.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ]
                        : [],
                  ),
                  ExpansionTile(
                    title: const Text(
                      'Go to DJ Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.teal),
                    onExpansionChanged: (value) {
                      setState(() {
                        _isRestaurant4Expanded = value;
                      });
                    },
                    children: _isRestaurant4Expanded
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                'Tasks 0/${tasks.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ]
                        : [],
                  ),
                  ExpansionTile(
                    title: const Text(
                      'Go to Jewellery & Accessories Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.teal),
                    onExpansionChanged: (value) {
                      setState(() {
                        _isRestaurant4Expanded = value;
                      });
                    },
                    children: _isRestaurant4Expanded
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                'Tasks 0/${tasks.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ]
                        : [],
                  ),
                ],
              ),
            ),
    );
  }
}