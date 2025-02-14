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

  // Function to determine the year based on the student_id
  String getYearFromStudentId(String studentId) {
    if (studentId.startsWith('64')) {
      return 'Year 4';
    } else if (studentId.startsWith('67')) {
      return 'Year 1';
    } else if (studentId.startsWith('66')) {
      return 'Year 2';
    } else if (studentId.startsWith('65')) {
      return 'Year 3';
    } else if (int.tryParse(studentId.substring(0, 2))! >= 68) {
      return 'Can\'t Add';
    } else if (int.tryParse(studentId.substring(0, 2))! < 64) {
      return 'Can\'t Add';
    } else {
      return 'Unknown';
    }
  }

  // Validate student_id format (6xxxxxxxx-x)
  bool validateStudentIdFormat(String studentId) {
    RegExp regex = RegExp(r"^6\d{8}-\d$");
    return regex.hasMatch(studentId);
  }

  // Function to get color based on year
  Color getColorBasedOnYear(String year) {
    switch (year) {
      case 'Year 1':
        return Colors.lightBlue;
      case 'Year 2':
        return Colors.pink;
      case 'Year 3':
        return Colors.orange;
      case 'Year 4':
        return Colors.yellow;
      case 'Graduated':
        return Colors.grey;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student List ")),
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
              String studentId = student['student_id'] ?? '';
              String year = getYearFromStudentId(studentId);

              // Get background color based on student year
              Color bgColor = getColorBasedOnYear(year);

              return Card(
                margin: const EdgeInsets.all(8.0),
                color: bgColor, // Set background color based on the year
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  side:
                      BorderSide(color: Colors.black, width: 2), // Black border
                ),
                child: ListTile(
                  title: Text(
                    "${student['name']}",
                    style: TextStyle(
                      fontFamily: 'Roboto', // Change font
                      color: Colors.black, // Font color to black
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Set font size
                    ),
                  ),
                  subtitle: Text(
                    "Student ID: $studentId\nBranch: ${student['branch']}\nYear: $year",
                    style: TextStyle(
                      fontFamily: 'Roboto', // Change font
                      color: Colors.black, // Font color to black
                      fontSize: 14, // Set font size
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (year != 'Can\'t Add') ...[
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          onPressed: () =>
                              _editStudent(context, docId, student),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.black),
                          onPressed: () => _deleteStudent(docId),
                        ),
                      ],
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String studentId = studentIdController.text;
                String year = getYearFromStudentId(studentId);

                // Validate student_id format
                if (nameController.text.isNotEmpty &&
                    studentId.isNotEmpty &&
                    branchController.text.isNotEmpty) {
                  if (!validateStudentIdFormat(studentId)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Invalid student ID format.')),
                    );
                    return;
                  }

                  if (year == 'Can\'t Add') {
                    // Show an error if the student ID is invalid (>= 68)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cannot add this student')),
                    );
                    Navigator.pop(context);
                  } else {
                    studentsCollection.add({
                      'name': nameController.text,
                      'student_id': studentId,
                      'branch': branchController.text,
                      'year': year,
                    });
                    Navigator.pop(context);
                  }
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String studentId = studentIdController.text;
                String year = getYearFromStudentId(studentId);

                // Validate student_id format
                if (nameController.text.isNotEmpty &&
                    studentId.isNotEmpty &&
                    branchController.text.isNotEmpty) {
                  if (!validateStudentIdFormat(studentId)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Invalid student ID format.')),
                    );
                    return;
                  }

                  if (year == 'Can\'t Add') {
                    // Show an error if the student ID is invalid (>= 68)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cannot edit this student')),
                    );
                    Navigator.pop(context);
                  } else {
                    FirebaseFirestore.instance
                        .collection('students')
                        .doc(docId)
                        .update({
                      'name': nameController.text,
                      'student_id': studentId,
                      'branch': branchController.text,
                      'year': year,
                    });
                    Navigator.pop(context);
                  }
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
