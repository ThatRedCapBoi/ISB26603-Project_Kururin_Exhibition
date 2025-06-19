class Admin {
  final int? id;
  final String name;
  final String password;
  final String email;

  Admin({
    required this.id,
    required this.name,
    required this.password,
    required this.email,
  });

  Map<String, Object?> toMap() {
    return {'adminName': name, 'adminPassword': password, 'adminEmail': email};
  }

  static Admin fromMap(Map<String, Object?> map) {
    return Admin(
      id: map['adminID'] as int?,
      name: map['adminName'] as String,
      password: map['adminPassword'] as String,
      email: map['adminEmail'] as String,
    );
  }
}
