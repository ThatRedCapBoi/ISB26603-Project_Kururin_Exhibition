class User {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String password;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'password': password,
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'] as int?,
    name: map['name'] as String? ?? '',
    email: map['email'] as String? ?? '',
    phone: map['phone'] as String? ?? '',
    password: map['password'] as String? ?? '',
  );
}
