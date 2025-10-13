import 'package:flutter/material.dart';
import 'package:wedding_planner/services/user_service.dart';

class AddSubTaskScreen extends StatefulWidget {
  final int taskIndex;

  const AddSubTaskScreen({super.key, required this.taskIndex});

  @override
  State<AddSubTaskScreen> createState() => _AddSubTaskScreenState();
}

class _AddSubTaskScreenState extends State<AddSubTaskScreen> {
  final _titleController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> subtasks = [];

  @override
  void initState() {
    super.initState();
    _fetchSubtasks();
  }

  Future<void> _fetchSubtasks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await UserService.getSubtasks(widget.taskIndex);
      if (result != null && result['subtasks'] is List) {
        setState(() {
          subtasks = List<Map<String, dynamic>>.from(result['subtasks']);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load subtasks: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addSubTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a subtask title')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await UserService.addSubtask(
        widget.taskIndex,
        _titleController.text,
      );
      if (result['success']) {
        setState(() {
          subtasks.add(result['subtask']);
          _titleController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subtask added successfully')),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add subtask: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Subtask', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Subtask Title',
                hintText: 'Enter subtask title',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addSubTask,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Save Subtask',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : subtasks.isEmpty
                      ? const Center(child: Text('No subtasks available'))
                      : ListView.builder(
                        itemCount: subtasks.length,
                        itemBuilder: (context, index) {
                          final subtask = subtasks[index];
                          return ListTile(
                            title: Text(
                              subtask['title'] ?? 'Unnamed Subtask',
                              style: const TextStyle(color: Colors.black),
                            ),
                            trailing: Icon(
                              subtask['completed']
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color:
                                  subtask['completed']
                                      ? Colors.green
                                      : Colors.grey,
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
