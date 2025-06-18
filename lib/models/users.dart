class User {
  int? id;
  String name;
  String email;
  String phone;
  String password;

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
        id: map['id'],
        name: map['name'],
        email: map['email'],
        phone: map['phone'],
        password: map['password'],
      );
}