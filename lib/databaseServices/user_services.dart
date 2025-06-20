import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:Project_Kururin_Exhibition/databaseServices/eventSphere_db.dart'; 

class UserServices {
  static final UserServices instance = UserServices._constructor();

  UserServices._constructor();

  Future<int> insertUser(User u) async {
    return await EventSphereDB.instance.insertUser(u);
  }

  Future<User?> getUserByEmail(String email) async {
    return await EventSphereDB.instance.getUserByEmail(email);
  }

  Future<int> updateUser(User u) async {
    return await EventSphereDB.instance.updateUser(u);
  }

  Future<List<User>> getAllUsers() async {
    return await EventSphereDB.instance.getAllUsers();
  }

  Future<int> deleteUser(int id) async {
    return await EventSphereDB.instance.deleteUser(id);
  }

}