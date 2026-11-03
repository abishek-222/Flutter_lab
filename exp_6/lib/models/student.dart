
class Student {
  final int? id;
  final String name;
  final String registerNumber;
  final String department;
  final String email;

  const Student({
    this.id,
    required this.name,
    required this.registerNumber,
    required this.department,
    required this.email,
  });

  // Convert Student object into a database Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'register_number': registerNumber,
      'department': department,
      'email': email,
    };
  }

  // Convert database Map into Student object
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int,
      name: map['name'] as String,
      registerNumber: map['register_number'] as String,
      department: map['department'] as String,
      email: map['email'] as String,
    );
  }
}
