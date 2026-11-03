
import 'package:flutter/material.dart';

import 'models/student.dart';
import 'database/database_helper.dart';

void main() {
  runApp(const StudentManagementApp());
}

// ROOT APPLICATION
class StudentManagementApp extends StatelessWidget {
  const StudentManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF4F5FA),
      ),
      home: const StudentHomePage(),
    );
  }
}

// MAIN STUDENT SCREEN
class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // INPUT CONTROLLERS
  final nameController = TextEditingController();
  final registerController = TextEditingController();
  final departmentController = TextEditingController();
  final emailController = TextEditingController();

  // STUDENT RECORDS
  List<Student> students = [];

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  // INITIALIZE DATABASE AND LOAD RECORDS
  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  // READ STUDENT RECORDS
  Future<void> loadStudents() async {
    try {
      final records =
          await DatabaseHelper.instance.getStudents();

      if (!mounted) return;

      setState(() {
        students = records;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // CREATE STUDENT RECORD
  Future<void> addStudent() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    final student = Student(
      name: nameController.text.trim(),
      registerNumber: registerController.text.trim(),
      department: departmentController.text.trim(),
      email: emailController.text.trim(),
    );

    try {
      await DatabaseHelper.instance.insertStudent(student);

      // Clear input fields
      nameController.clear();
      registerController.clear();
      departmentController.clear();
      emailController.clear();

      // Retrieve updated records
      await loadStudents();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // RELEASE CONTROLLERS
  @override
  void dispose() {
    nameController.dispose();
    registerController.dispose();
    departmentController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // INPUT FIELD WIDGET
  Widget buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: validator ?? (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  // BUILD APPLICATION
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // APP BAR
      appBar: AppBar(
        title: const Text(
          'Student Management System',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 850,
          ),

          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [

              // HEADER
              const Icon(
                Icons.school,
                color: Colors.indigo,
                size: 65,
              ),

              const SizedBox(height: 10),

              const Text(
                'Student Record Management',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Add and retrieve student records using SQLite.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 25),

              // STUDENT REGISTRATION FORM
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Form(
                    key: _formKey,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          'Add Student Details',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // STUDENT NAME
                        buildInputField(
                          label: 'Student Name',
                          hint: 'Enter student name',
                          icon: Icons.person,
                          controller: nameController,
                        ),

                        // REGISTER NUMBER
                        buildInputField(
                          label: 'Register Number',
                          hint: 'Example: 23CSE101',
                          icon: Icons.badge,
                          controller: registerController,
                        ),

                        // DEPARTMENT
                        buildInputField(
                          label: 'Department',
                          hint: 'Example: Computer Science',
                          icon: Icons.school,
                          controller: departmentController,
                        ),

                        // EMAIL
                        buildInputField(
                          label: 'Email Address',
                          hint: 'Enter email address',
                          icon: Icons.email,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter email address';
                            }

                            final emailRegex = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            );

                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Enter a valid email address';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        // SAVE BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,

                          child: ElevatedButton.icon(
                            onPressed: isSaving ? null : addStudent,

                            icon: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.save,
                                    color: Colors.white,
                                  ),

                            label: Text(
                              isSaving
                                  ? 'Saving...'
                                  : 'Save Student',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // STUDENT RECORDS HEADING
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saved Student Records',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    '${students.length} Students',
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // REFRESH BUTTON
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: loadStudents,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Records'),
                ),
              ),

              // LOADING INDICATOR
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )

              // DATABASE ERROR
              else if (errorMessage != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Database error: $errorMessage',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )

              // EMPTY RECORDS
              else if (students.isEmpty)
                const Card(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 50,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No student records found.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Add a student using the form above.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              // DISPLAY STUDENT RECORDS
              else
                ...students.map((student) {

                  return Card(
                    color: Colors.white,
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),

                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),

                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.indigo.shade50,
                        child: Text(
                          student.name.isNotEmpty
                              ? student.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),

                      title: Text(
                        student.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Register No: ${student.registerNumber}',
                            ),
                            Text(
                              'Department: ${student.department}',
                            ),
                            Text(
                              'Email: ${student.email}',
                            ),
                            Text(
                              'Database ID: ${student.id}',
                              style: const TextStyle(
                                color: Colors.indigo,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
