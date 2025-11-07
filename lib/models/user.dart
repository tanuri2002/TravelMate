class User {
  String id;
  String name;
  String email;

  User({required this.id, required this.name, required this.email});

  void updateProfile(String newName, String newEmail) {
    name = newName;
    email = newEmail;
  }
}
