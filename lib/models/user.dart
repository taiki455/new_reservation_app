class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // "user" or "admin"

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == 'admin';
}

