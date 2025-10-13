import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wedding_planner/screens/add_task_screen.dart';
import 'package:wedding_planner/screens/add_sub_task_screen.dart';
import 'package:wedding_planner/screens/planning_screen.dart';
import 'package:wedding_planner/services/user_service.dart';

class CheckListScreen extends StatefulWidget {
  const CheckListScreen({super.key});

  @override
  State<CheckListScreen> createState() => _CheckListScreenState();
}

class _CheckListScreenState extends State<CheckListScreen> {
  // Hive boxes
  late Box<bool> defaultTaskBox;
  late Box<bool> defaultDescriptionBox;
  late Box<bool> userTaskBox;
  late Box<bool> userSubtaskBox;
  
  // Default tasks defined as a constant list
  final List<Map<String, dynamic>> defaultTasks = [
    {
      'name': 'Find Your Venues',
      'completed': false,
      'deadline': null,
      'timeline': 'Before 1 year - 6 months',
      'subtasks': [],
      'isDefault': true,
      'description': [
        {
          'text':
              'Start by having a conversation with your future bride or groom about your must-have features. '
              'Does it matter to you if your guests can stay the night, if you’re the only ones to use the venue that day, '
              'or how many people it can hold?',
          'completed': false,
        },
        {
          'text':
              'Add all your specific criteria to our advanced filters to find the venue of your dreams! '
              'Send a message to your favorite space to start your negotiations process early directly on Wedding Planning Assistant.',
          'completed': false,
        },
        {
          'text':
              'Request to visit all the venues you’re interested in. Make sure you denote who will be joining you. '
              'Try to visit as many venues as you can in one trip - that way you’ll be able to easier compare them.',
          'completed': false,
        },
        {
          'text':
              'Remember, you’re not only investigating the venue, you’re also choosing the team that will handle it for your big day! '
              'Make sure you get to know them, too.',
          'completed': false,
        },
      ],
    },
    {
      'name': 'Make Your Venue Choice',
      'completed': false,
      'deadline': null,
      'timeline': 'Before 1 year - 6 months',
      'subtasks': [],
      'isDefault': true,
      'description': [
        {
          'text':
              'Everybody who came with you on your visits will doubtless have feedback for you. Listen to their opinions, but remember that it’s your wedding. The final decision lies with you!',
          'completed': false,
        },
        {
          'text':
              'Compare venue pricing and availability with the availability of your closest friends and family.',
          'completed': false,
        },
        {
          'text':
              'Get a detailed quote and a draft contract. Go over this with an eagle eye - you don’t want any surprises down the road!',
          'completed': false,
        },
      ],
    },
    {
      'name': 'Book Your Venue',
      'completed': false,
      'deadline': null,
      'timeline': 'Before 1 year - 6 months',
      'subtasks': [],
      'isDefault': true,
      'description': [
        {
          'text': 'Choose the venue you want to get married at!.',
          'completed': false,
        },
        {
          'text':
              'Notify your venue that you would like to book them. Make sure they block out your date to avoid double-bookings or cancellations.',
          'completed': false,
        },
        {
          'text': 'Before you sign the contract, do one last review.',
          'completed': false,
        },
        {
          'text':
              'Sign your contract. Then, make a copy of the signed contract and pay your deposit.',
          'completed': false,
        },
        {
          'text':
              'Mark your venue as booked, then detract the sum from your total budget.',
          'completed': false,
        },
        {
          'text':
              'Add your official wedding date to your Wedding Project and pop the champagne! You’re getting married!',
          'completed': false,
        },
      ],
    },
    {
      'name': 'Find A Florist',
      'completed': false,
      'deadline': null,
      'timeline': 'Before 6 months',
      'subtasks': [],
      'isDefault': true,
      'description': [
        {
          'text':
              'Gather some images of floral arrangements that you like from the internet or magazines.',
          'completed': false,
        },
        {
          'text':
              'Browse florists on Wedding Planning Assistant and add the ones you like to your projects.',
          'completed': false,
        },
        {
          'text': 'Contact your preferred florists and arrange a meeting.',
          'completed': false,
        },
        {'text': 'Mark it as booked!', 'completed': false},
      ],
    },
    {
      'name': 'Food, Glorious Food',
      'completed': false,
      'deadline': null,
      'timeline': 'Before 6 months',
      'subtasks': [],
      'isDefault': true,
      'description': [
        {
          'text':
              'After discussing your desired menu with your partner, browse our list of caterers using the search function.',
          'completed': false,
        },
        {
          'text':
              'Contact your desired caterers to check their availability and arrange tastings. Bon appetit!',
          'completed': false,
        },
        {'text': 'Book your favorite caterer!', 'completed': false},
      ],
    },
  ];

  // User-added tasks
  List<Map<String, dynamic>> userTasks = [];
  int completedSubtasks = 0;
  int totalSubtasks = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      // Open Hive boxes
      defaultTaskBox = await Hive.openBox<bool>('defaultTasks');
      defaultDescriptionBox = await Hive.openBox<bool>('defaultDescriptions');
      userTaskBox = await Hive.openBox<bool>('userTasks');
      userSubtaskBox = await Hive.openBox<bool>('userSubtasks');
      
      await _fetchTasks();
    } catch (e) {
      print('Error initializing Hive: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchTasks() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedTasks = await UserService.getTasks();
      setState(() {
        userTasks =
            (fetchedTasks as List<dynamic>)
                .map((task) => Map<String, dynamic>.from(task as Map))
                .toList();
        for (var task in userTasks) {
          if (task['subtasks'] != null && task['subtasks'] is List) {
            task['subtasks'] =
                (task['subtasks'] as List<dynamic>)
                    .map((subtask) => Map<String, dynamic>.from(subtask as Map))
                    .toList();
          } else {
            task['subtasks'] = <Map<String, dynamic>>[];
          }
        }
        
        // Load saved states from Hive
        _loadSavedStates();
        
        // Check completion status
        for (var task in userTasks) {
          _checkTaskCompletion(task);
        }
        for (var task in defaultTasks) {
          _checkTaskCompletion(task);
        }
        
        isLoading = false;
        _updateCompletionProgress();
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

  void _loadSavedStates() {
    // Load default task states
    for (int taskIndex = 0; taskIndex < defaultTasks.length; taskIndex++) {
      final task = defaultTasks[taskIndex];
      
      // Load task completion state
      final taskKey = 'default_task_$taskIndex';
      task['completed'] = defaultTaskBox.get(taskKey, defaultValue: false);
      
      // Load description completion states
      final descriptions = task['description'] as List<Map<String, dynamic>>;
      for (int descIndex = 0; descIndex < descriptions.length; descIndex++) {
        final descKey = 'default_task_${taskIndex}_desc_$descIndex';
        descriptions[descIndex]['completed'] = 
            defaultDescriptionBox.get(descKey, defaultValue: false);
      }
    }
    
    // Load user task states
    for (int taskIndex = 0; taskIndex < userTasks.length; taskIndex++) {
      final task = userTasks[taskIndex];
      
      // Load task completion state
      final taskKey = 'user_task_$taskIndex';
      task['completed'] = userTaskBox.get(taskKey, defaultValue: false);
      
      // Load subtask completion states
      final subtasks = task['subtasks'] as List<Map<String, dynamic>>;
      for (int subtaskIndex = 0; subtaskIndex < subtasks.length; subtaskIndex++) {
        final subtaskKey = 'user_task_${taskIndex}_subtask_$subtaskIndex';
        subtasks[subtaskIndex]['completed'] = 
            userSubtaskBox.get(subtaskKey, defaultValue: false);
      }
    }
  }

  Future<void> _saveDefaultTaskState(int taskIndex, bool completed) async {
    final taskKey = 'default_task_$taskIndex';
    await defaultTaskBox.put(taskKey, completed);
  }

  Future<void> _saveDefaultDescriptionState(int taskIndex, int descIndex, bool completed) async {
    final descKey = 'default_task_${taskIndex}_desc_$descIndex';
    await defaultDescriptionBox.put(descKey, completed);
  }

  Future<void> _saveUserTaskState(int taskIndex, bool completed) async {
    final taskKey = 'user_task_$taskIndex';
    await userTaskBox.put(taskKey, completed);
  }

  Future<void> _saveUserSubtaskState(int taskIndex, int subtaskIndex, bool completed) async {
    final subtaskKey = 'user_task_${taskIndex}_subtask_$subtaskIndex';
    await userSubtaskBox.put(subtaskKey, completed);
  }

  void _checkTaskCompletion(Map<String, dynamic> task) {
    if (task['isDefault'] == true) {
      final descriptions = task['description'] as List<Map<String, dynamic>>;
      task['completed'] = descriptions.every(
        (desc) => desc['completed'] == true,
      );
    } else {
      final subtasks = task['subtasks'] as List<Map<String, dynamic>>;
      task['completed'] =
          subtasks.isNotEmpty &&
          subtasks.every((subtask) => subtask['completed'] == true);
    }
  }

  void _updateCompletionProgress() {
    setState(() {
      int completedCount = 0;
      int totalCount = 0;

      // Count default tasks' descriptions
      for (var task in defaultTasks) {
        final descriptions = task['description'] as List<Map<String, dynamic>>;
        totalCount += descriptions.length;
        completedCount +=
            descriptions.where((desc) => desc['completed'] == true).length;
      }

      // Count user tasks' subtasks
      for (var task in userTasks) {
        final subtasks = task['subtasks'] as List<Map<String, dynamic>>;
        totalCount += subtasks.length;
        completedCount +=
            subtasks.where((subtask) => subtask['completed'] == true).length;
      }

      completedSubtasks = completedCount;
      totalSubtasks = totalCount;
    });
  }

  Future<void> _deleteTask(int taskIndex) async {
    setState(() {
      isLoading = true;
    });
    try {
      final result = await UserService.deleteTask(taskIndex);
      if (result['success']) {
        // Remove saved states from Hive
        await _removeUserTaskFromHive(taskIndex);
        
        setState(() {
          userTasks.removeAt(taskIndex);
          _updateCompletionProgress();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete task: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _removeUserTaskFromHive(int taskIndex) async {
    final taskKey = 'user_task_$taskIndex';
    await userTaskBox.delete(taskKey);
    
    // Remove all subtasks for this task
    final task = userTasks[taskIndex];
    final subtasks = task['subtasks'] as List<Map<String, dynamic>>;
    for (int subtaskIndex = 0; subtaskIndex < subtasks.length; subtaskIndex++) {
      final subtaskKey = 'user_task_${taskIndex}_subtask_$subtaskIndex';
      await userSubtaskBox.delete(subtaskKey);
    }
  }

  Future<void> _deleteSubtask(int taskIndex, int subtaskIndex) async {
    setState(() {
      isLoading = true;
    });
    try {
      final result = await UserService.deleteSubtask(taskIndex, subtaskIndex);
      if (result['success']) {
        // Remove saved state from Hive
        final subtaskKey = 'user_task_${taskIndex}_subtask_$subtaskIndex';
        await userSubtaskBox.delete(subtaskKey);
        
        setState(() {
          userTasks[taskIndex]['subtasks'].removeAt(subtaskIndex);
          _checkTaskCompletion(userTasks[taskIndex]);
          _updateCompletionProgress();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete subtask: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Task Completion',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$completedSubtasks/$totalSubtasks',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: totalSubtasks == 0 ? 0.0 : completedSubtasks / totalSubtasks,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00BCD4)),
          ),
          const SizedBox(height: 4),
          Text(
            totalSubtasks == 0
                ? '0%'
                : '${((completedSubtasks / totalSubtasks) * 100).round()}% Complete',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultTaskTile(Map<String, dynamic> task, int taskIndex) {
    final completedDescriptions =
        (task['description'] as List<Map<String, dynamic>>)
            .where((desc) => desc['completed'] == true)
            .length;
    final totalDescriptions = task['description'].length;

    return Theme(
      data: Theme.of(
        context,
      ).copyWith(iconTheme: const IconThemeData(color: Colors.black)),
      child: ExpansionTile(
        title: Row(
          children: [
            Checkbox(
              value: task['completed'] ?? false,
              onChanged: (bool? value) async {
                setState(() {
                  task['completed'] = value ?? false;
                  // Update all descriptions if task is checked/unchecked
                  for (int descIndex = 0; descIndex < task['description'].length; descIndex++) {
                    task['description'][descIndex]['completed'] = value ?? false;
                    // Save each description state
                    _saveDefaultDescriptionState(taskIndex, descIndex, value ?? false);
                  }
                  _updateCompletionProgress();
                });
                // Save task state
                await _saveDefaultTaskState(taskIndex, value ?? false);
              },
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.green;
                }
                return Colors.white;
              }),
              checkColor: Colors.white,
            ),
            Expanded(
              child: Text(
                task['name'] ?? '',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  decoration:
                      task['completed'] == true
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '($completedDescriptions/$totalDescriptions)',
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
            const Icon(Icons.expand_more, color: Colors.black),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  (task['description'] as List<Map<String, dynamic>>)
                      .asMap()
                      .entries
                      .map((entry) {
                        final descIndex = entry.key;
                        final desc = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: desc['completed'] ?? false,
                                onChanged: (bool? value) async {
                                  setState(() {
                                    task['description'][descIndex]['completed'] =
                                        value ?? false;
                                    _checkTaskCompletion(task);
                                    _updateCompletionProgress();
                                  });
                                  // Save description state and task state
                                  await _saveDefaultDescriptionState(taskIndex, descIndex, value ?? false);
                                  await _saveDefaultTaskState(taskIndex, task['completed']);
                                },
                                fillColor: WidgetStateProperty.resolveWith<
                                  Color
                                >((states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Colors.green;
                                  }
                                  return Colors.white;
                                }),
                                checkColor: Colors.white,
                              ),
                              Expanded(
                                child: Text(
                                  '${desc['text']}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    decoration:
                                        desc['completed'] == true
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTaskTile(Map<String, dynamic> task, int index) {
    final completedSubtasks =
        task['subtasks'] != null && task['subtasks'] is List
            ? (task['subtasks'] as List<Map<String, dynamic>>)
                .where((subtask) => subtask['completed'] == true)
                .length
            : 0;
    final totalSubtasks = task['subtasks']?.length ?? 0;

    return Theme(
      data: Theme.of(
        context,
      ).copyWith(iconTheme: const IconThemeData(color: Colors.black)),
      child: ExpansionTile(
        title: Row(
          children: [
            Checkbox(
              value: task['completed'] ?? false,
              onChanged: (bool? value) async {
                setState(() {
                  task['completed'] = value ?? false;
                  // Update all subtasks if task is checked/unchecked
                  if (task['subtasks'] != null && task['subtasks'] is List) {
                    for (int subtaskIndex = 0; subtaskIndex < task['subtasks'].length; subtaskIndex++) {
                      task['subtasks'][subtaskIndex]['completed'] = value ?? false;
                      // Save each subtask state
                      _saveUserSubtaskState(index, subtaskIndex, value ?? false);
                    }
                  }
                  _updateCompletionProgress();
                });
                // Save task state
                await _saveUserTaskState(index, value ?? false);
              },
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.green;
                }
                return Colors.white;
              }),
              checkColor: Colors.white,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddSubTaskScreen(taskIndex: index),
                    ),
                  ).then((refresh) {
                    if (refresh == true) _fetchTasks();
                  });
                },
                child: Text(
                  task['name'] ?? '',
                  style: TextStyle(
                    color: Colors.black,
                    decoration:
                        task['completed'] == true
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          'Deadline: ${task['deadline']?.split('T')[0] ?? 'No deadline'}\nTimeline: ${task['timeline'] ?? 'No timeline'}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '($completedSubtasks/$totalSubtasks)',
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _deleteTask(index);
              },
            ),
          ],
        ),
        children: [
          if (task['subtasks'] != null &&
              task['subtasks'] is List &&
              task['subtasks'].isNotEmpty)
            ...task['subtasks'].asMap().entries.map((entry) {
              final subtaskIndex = entry.key;
              final subtask = entry.value as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                            value: subtask['completed'] ?? false,
                            onChanged: (bool? value) async {
                              setState(() {
                                task['subtasks'][subtaskIndex]['completed'] =
                                    value ?? false;
                                _checkTaskCompletion(task);
                                _updateCompletionProgress();
                              });
                              // Save subtask state and task state
                              await _saveUserSubtaskState(index, subtaskIndex, value ?? false);
                              await _saveUserTaskState(index, task['completed']);
                            },
                            fillColor: WidgetStateProperty.resolveWith<Color>((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.green;
                              }
                              return Colors.white;
                            }),
                            checkColor: Colors.white,
                          ),
                          Expanded(
                            child: Text(
                              subtask['title'] ?? 'Unnamed Subtask',
                              style: TextStyle(
                                color: Colors.black,
                                decoration:
                                    subtask['completed'] == true
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _deleteSubtask(index, subtaskIndex);
                      },
                    ),
                  ],
                ),
              );
            }),
          ListTile(
            title: const Text('Add New Subtask'),
            trailing: const Icon(Icons.add_circle, color: Colors.green),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddSubTaskScreen(taskIndex: index),
                ),
              ).then((refresh) {
                if (refresh == true) _fetchTasks();
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Checklist', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProgressIndicator(),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        // Default tasks
                        ...defaultTasks.asMap().entries.map((entry) {
                          final taskIndex = entry.key;
                          final task = entry.value;
                          return _buildDefaultTaskTile(task, taskIndex);
                        }),
                        // User-added tasks
                        ...userTasks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final task = entry.value;
                          return _buildUserTaskTile(task, index);
                        }),
                        // Add new task button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddTaskScreen(),
                                ),
                              ).then((_) => _fetchTasks());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00BCD4),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('+ Add New Task'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  @override
  void dispose() {
    // Close Hive boxes when disposing
    defaultTaskBox.close();
    defaultDescriptionBox.close();
    userTaskBox.close();
    userSubtaskBox.close();
    super.dispose();
  }
}