import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// ==================== MY APP ====================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

// ==================== HOME PAGE ====================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> tasks = [
    'Complete Flutter UI',
    'Learn ListView',
    'Practice Dart',
  ];

  List<String> taskDescriptions = [
    'Create a clean Flutter UI',
    'Practice ListView and ListTile',
    'Practice Dart basics',
  ];

  List<bool> taskCompleted = [false, true, false];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // ==================== SAVE TASKS ====================

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('tasks', tasks);

    await prefs.setStringList('taskDescriptions', taskDescriptions);

    await prefs.setStringList(
      'taskCompleted',
      taskCompleted.map((value) => value.toString()).toList(),
    );
  }

  // ==================== LOAD TASKS ====================

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTasks = prefs.getStringList('tasks');
    final savedDescriptions = prefs.getStringList('taskDescriptions');
    final savedTaskCompleted = prefs.getStringList('taskCompleted');

    if (savedTasks != null &&
        savedDescriptions != null &&
        savedTaskCompleted != null) {
      setState(() {
        tasks = savedTasks;
        taskDescriptions = savedDescriptions;

        taskCompleted = savedTaskCompleted
            .map((value) => value == 'true')
            .toList();
      });
    }
  }

  List<int> get filteredTaskIndexes {
    final query = searchController.text.toLowerCase();

    return List.generate(
      tasks.length,
      (index) => index,
    ).where((index) => tasks[index].toLowerCase().contains(query)).toList();
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    int totalTasks = tasks.length;

    int completedTasks = taskCompleted.where((completed) => completed).length;

    int pendingTasks = totalTasks - completedTasks;

    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================== SUMMARY ====================
            const Text(
              'Task Summary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                // TOTAL
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        children: [
                          Text(
                            '$totalTasks',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Text('Total'),
                        ],
                      ),
                    ),
                  ),
                ),

                // PENDING
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        children: [
                          Text(
                            '$pendingTasks',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Text('Pending'),
                        ],
                      ),
                    ),
                  ),
                ),

                // DONE
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        children: [
                          Text(
                            '$completedTasks',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Text('Done'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==================== ADD TASK ====================
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () async {
                  final newTask = await Navigator.push<TaskData>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTaskPage(),
                    ),
                  );

                  if (newTask != null) {
                    setState(() {
                      tasks.add(newTask.title);

                      taskDescriptions.add(newTask.description);

                      taskCompleted.add(false);

                      saveTasks();
                    });
                  }
                },

                icon: const Icon(Icons.add),

                label: const Text('Add Task'),
              ),
            ),

            const SizedBox(height: 20),

            // ==================== TASK TITLE ====================
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                });
              },
              decoration: const InputDecoration( 
                hintText: 'Search task...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
               
              ),
  
            const SizedBox(height: 10),

            const Text(
              'My Tasks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // ==================== TASK LIST ====================
            Expanded(
              child: ListView.builder(
                itemCount: filteredTaskIndexes.length,

                itemBuilder: (context, itemIndex) {
                  final index = filteredTaskIndexes[itemIndex];

                  return Card(
                    child: ListTile(
                      // CHECKBOX
                      leading: Checkbox(
                        value: taskCompleted[index],

                        onChanged: (value) {
                          setState(() {
                            taskCompleted[index] = value ?? false;

                            saveTasks();
                          });
                        },
                      ),

                      // TITLE
                      title: Text(
                        tasks[index],

                        style: TextStyle(
                          decoration: taskCompleted[index]
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),

                      // DESCRIPTION
                      subtitle: Text(taskDescriptions[index]),

                      // EDIT + DELETE
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          // EDIT
                          IconButton(
                            icon: const Icon(Icons.edit),

                            onPressed: () async {
                              final updatedTask =
                                  await Navigator.push<TaskData>(
                                    context,

                                    MaterialPageRoute(
                                      builder: (context) => AddTaskPage(
                                        initialTask: tasks[index],

                                        initialDescription:
                                            taskDescriptions[index],
                                      ),
                                    ),
                                  );

                              if (updatedTask != null) {
                                setState(() {
                                  tasks[index] = updatedTask.title;

                                  taskDescriptions[index] =
                                      updatedTask.description;

                                  saveTasks();
                                });
                              }
                            },
                          ),

                          // DELETE
                          IconButton(
                            icon: const Icon(Icons.delete),

                            onPressed: () {
                              setState(() {
                                tasks.removeAt(index);

                                taskDescriptions.removeAt(index);

                                taskCompleted.removeAt(index);

                                saveTasks();
                              });
                            },
                          ),
                        ],
                      ),
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

// ==================== TASK DATA ====================

class TaskData {
  final String title;
  final String description;

  TaskData({required this.title, required this.description});
}

// ==================== ADD / EDIT TASK PAGE ====================

class AddTaskPage extends StatefulWidget {
  final String? initialTask;
  final String? initialDescription;

  const AddTaskPage({super.key, this.initialTask, this.initialDescription});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  late final TextEditingController taskNameController;

  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();

    taskNameController = TextEditingController(text: widget.initialTask ?? '');

    descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
  }

  @override
  void dispose() {
    taskNameController.dispose();

    descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialTask != null ? 'Edit Task' : 'Add Task'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // ==================== TASK NAME ====================
            TextField(
              controller: taskNameController,

              decoration: const InputDecoration(
                labelText: 'Task Name',
                hintText: 'Enter your task',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ==================== DESCRIPTION ====================
            TextField(
              controller: descriptionController,

              maxLines: 3,

              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ==================== SAVE BUTTON ====================
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  final taskName = taskNameController.text.trim();

                  final description = descriptionController.text.trim();

                  if (taskName.isNotEmpty) {
                    Navigator.pop(
                      context,

                      TaskData(title: taskName, description: description),
                    );
                  }
                },

                child: const Text('Save Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
