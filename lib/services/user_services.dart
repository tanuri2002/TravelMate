import '../models/user.dart';

class UserService {
  final List<User> _users = [];

  void addUser(User user) {
    _users.add(user);
  }

  User? getUserById(String id) {
    return _users.firstWhere((u) => u.id == id, orElse: () => User(id: "", name: "", email: ""));
  }

  void updateUser(String id, String newName, String newEmail) {
    final user = _users.firstWhere((u) => u.id == id, orElse: () => User(id: "", name: "", email: ""));
    if (user.id.isNotEmpty) {
      user.updateProfile(newName, newEmail);
    }
  }
}
