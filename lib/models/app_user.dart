class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'employee' or 'manager'

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? 'کاربر',
      email: map['email'] ?? '',
      role: map['role'] ?? 'employee',
    );
  }
}
