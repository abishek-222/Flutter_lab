class Student {
  final String id;
  final String name;
  final String registerNumber;
  final String department;
  final String email;

  const Student({
    required this.id,
    required this.name,
    required this.registerNumber,
    required this.department,
    required this.email,
  });

  factory Student.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Student(
      id: id,
      name: map['name'] ?? '',
      registerNumber: map['registerNumber'] ?? '',
      department: map['department'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'registerNumber': registerNumber,
      'department': department,
      'email': email,
    };
  }
}