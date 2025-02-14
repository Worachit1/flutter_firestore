import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentListScreen extends StatelessWidget {
  final CollectionReference studentsCollection =
      FirebaseFirestore.instance.collection('students');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student List")),
      body: StreamBuilder<QuerySnapshot>(
        stream: studentsCollection.snapshots(), // Listen for real-time updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading state
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No students found."));
          }

          var students = snapshot.data!.docs;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              var student = students[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text("${student['name']} ${student['lastname']}"),
                  subtitle: Text(
                      "ID: ${student['student-id']} | Room: ${student['room_id']}"),
                  leading: CircleAvatar(child: Text(student['name'][0])),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
