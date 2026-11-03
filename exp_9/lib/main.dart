import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'models/student.dart';
import 'services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const StudentUpdateApp());
}

class StudentUpdateApp extends StatelessWidget {
  const StudentUpdateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firestore Student Update',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF3F4FA),
        useMaterial3: true,
      ),
      home: const StudentUpdatePage(),
    );
  }
}

class StudentUpdatePage extends StatefulWidget {
  const StudentUpdatePage({super.key});

  @override
  State<StudentUpdatePage> createState() =>
      _StudentUpdatePageState();
}

class _StudentUpdatePageState extends State<StudentUpdatePage> {
  final FirestoreService firestoreService = FirestoreService();

  // Open the edit form
  Future<void> editStudent(Student student) async {
    final formKey = GlobalKey<FormState>();

    final nameController =
        TextEditingController(text: student.name);

    final registerController =
        TextEditingController(text: student.registerNumber);

    final departmentController =
        TextEditingController(text: student.department);

    final emailController =
        TextEditingController(text: student.email);

    bool isUpdating = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Update Student Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildInputField(
                          controller: nameController,
                          label: 'Student Name',
                          icon: Icons.person,
                        ),

                        buildInputField(
                          controller: registerController,
                          label: 'Register Number',
                          icon: Icons.badge,
                        ),

                        buildInputField(
                          controller: departmentController,
                          label: 'Department',
                          icon: Icons.school,
                        ),

                        buildInputField(
                          controller: emailController,
                          label: 'Email Address',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter email address';
                            }

                            final pattern = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            );

                            if (!pattern.hasMatch(value.trim())) {
                              return 'Enter a valid email';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: isUpdating
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Cancel'),
                ),

                ElevatedButton.icon(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() {
                            isUpdating = true;
                          });

                          final updatedStudent = Student(
                            id: student.id,
                            name: nameController.text.trim(),
                            registerNumber:
                                registerController.text.trim(),
                            department:
                                departmentController.text.trim(),
                            email: emailController.text.trim(),
                          );

                          try {
                            await firestoreService.updateStudent(
                              updatedStudent,
                            );

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext);

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Student updated successfully!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (error) {
                            setDialogState(() {
                              isUpdating = false;
                            });

                            if (!dialogContext.mounted) return;

                            ScaffoldMessenger.of(dialogContext)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Update failed: $error',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  icon: isUpdating
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    isUpdating ? 'Updating...' : 'Update',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    registerController.dispose();
    departmentController.dispose();
    emailController.dispose();
  }

  // Reusable text field
  Widget buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Student record card
  Widget buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.indigo.shade100,
              child: Text(
                student.name.isNotEmpty
                    ? student.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.indigo,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text('Register No: ${student.registerNumber}'),
                  Text('Department: ${student.department}'),
                  Text('Email: ${student.email}'),

                  const SizedBox(height: 5),

                  Text(
                    'Document ID: ${student.id}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              tooltip: 'Edit Student',
              onPressed: () => editStudent(student),
              icon: const Icon(
                Icons.edit,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Record Update',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),

      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Select a student and edit the existing information.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: firestoreService.getStudents(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading records: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final students = snapshot.data ?? [];

                if (students.isEmpty) {
                  return const Center(
                    child: Text(
                      'No student records available.',
                      style: TextStyle(fontSize: 17),
                    ),
                  );
                }

                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${students.length} Students',
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    ...students.map(
                      (student) => buildStudentCard(student),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}