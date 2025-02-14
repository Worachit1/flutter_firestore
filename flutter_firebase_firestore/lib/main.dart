import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StudentListScreen(),
    );
  }
}

class StudentListScreen extends StatelessWidget {
  final CollectionReference studentsCollection =
      FirebaseFirestore.instance.collection('students');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student List")),
      body: StreamBuilder<QuerySnapshot>(
        stream: studentsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No students found."));
          }

          var students = snapshot.data!.docs;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              var student = students[index].data() as Map<String, dynamic>;
              String docId = students[index].id; // Firestore document ID

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text("${student['name']}"),
                  subtitle: Text(
                    "Student ID: ${student['student_id']}\nBranch: ${student['branch']}\nYear: ${student['Year']}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editStudent(context, docId, student),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteStudent(docId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addStudent(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Function to add a new student
  void _addStudent(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController studentIdController = TextEditingController();
    TextEditingController branchController = TextEditingController();
    TextEditingController yearController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Student"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: studentIdController,
                decoration: const InputDecoration(labelText: "Student ID"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: branchController,
                decoration: const InputDecoration(labelText: "Branch"),
              ),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: "Year"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    studentIdController.text.isNotEmpty &&
                    branchController.text.isNotEmpty &&
                    yearController.text.isNotEmpty) {
                  studentsCollection.add({
                    'name': nameController.text,
                    'student_id': studentIdController.text,
                    'branch': branchController.text,
                    'Year': yearController.text,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Function to edit student data
  void _editStudent(
      BuildContext context, String docId, Map<String, dynamic> currentData) {
    TextEditingController nameController =
        TextEditingController(text: currentData['name']);
    TextEditingController studentIdController =
        TextEditingController(text: currentData['student_id']);
    TextEditingController branchController =
        TextEditingController(text: currentData['branch']);
    TextEditingController yearController =
        TextEditingController(text: currentData['Year']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Student"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: studentIdController,
                decoration: const InputDecoration(labelText: "Student ID"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: branchController,
                decoration: const InputDecoration(labelText: "Branch"),
              ),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: "Year"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    studentIdController.text.isNotEmpty &&
                    branchController.text.isNotEmpty &&
                    yearController.text.isNotEmpty) {
                  studentsCollection.doc(docId).update({
                    'name': nameController.text,
                    'student_id': studentIdController.text,
                    'branch': branchController.text,
                    'Year': yearController.text,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a student
  void _deleteStudent(String docId) {
    studentsCollection.doc(docId).delete();
  }
}
