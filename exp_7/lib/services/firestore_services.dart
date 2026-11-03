import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class FirestoreService {
  final CollectionReference<Map<String, dynamic>> studentsCollection =
      FirebaseFirestore.instance.collection('students');

  // CREATE: Add a student
  Future<void> addStudent(Student student) async {
    await studentsCollection.add(student.toMap());
  }

  // READ: Retrieve all students in real time
  Stream<List<Student>> getStudents() {
    return studentsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Student.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
}