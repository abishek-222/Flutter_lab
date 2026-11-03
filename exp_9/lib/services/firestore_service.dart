import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class FirestoreService {
  final CollectionReference<Map<String, dynamic>> studentsCollection =
      FirebaseFirestore.instance.collection('students');

  // READ: Retrieve all student records
  Stream<List<Student>> getStudents() {
    return studentsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Student.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // UPDATE: Update an existing student document
  Future<void> updateStudent(Student student) async {
    await studentsCollection
        .doc(student.id)
        .update(student.toMap());
  }
}