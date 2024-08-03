import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

// import 'package:flutter_provider/flutter_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sap_app/models/user.dart';

import '../data/app_keys.dart';

class UsersNotifier extends StateNotifier<List<User>> {
  UsersNotifier() : super([]);

  final String _error = "";
  User? currentUser;


  Future loadedAllUsers() async {
    final url = Uri.https(
        project_rtdb, 'users-list.json');

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        // setState(() {
        //   _error = "Failed to fetch data. Please try again later.";
        // });
        // return;
        print("ERROR: inside of users");
      }

      if (response.body == 'null') {
        return;
      }

      final Map<String, dynamic> listData =
      json.decode(utf8.decode(response.bodyBytes));

      final List<User> loadedUsers = [];

      for (final item in listData.entries) {
        loadedUsers.add(User(
            id: item.key as String,
            isAdmin: item.value["isAdmin"] as bool,
            login: item.value["login"] as String,
            password: item.value["password"]));
      }

      state = loadedUsers;

      return loadedUsers;
      // print(loadedUsers);
      // setState(() {
      //   _ProductItems = loadedItems;
      //   _isLoading = false;
      // });
    } catch (error) {
      // setState(() {
      //   _error = "Something went wrong!";
      // });
    }
  }

  bool checkIfExist(String login, String password) {
    bool IsExisting = state.any((element) => element.login == login && element.password==password);

    return IsExisting;
  }

  bool checkLogin(String login){
    bool IsExisting = state.any((element) => element.login == login);

    return IsExisting;
  }


  Future<bool> addUser(String login, String password, bool isAdmin) async {
    final url = Uri.https(project_rtdb, 'users-list.json');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'login': login,
            'password': password,
            'isAdmin': isAdmin,
          },
        ),
      );

      final Map<String, dynamic> resData = json.decode(utf8.decode(response.bodyBytes));

      state = [
        ...state,
        User(
            id: resData['name'],
            isAdmin: isAdmin,
            login: login,
            password: password
        )
      ];
      return true;
    } catch (error) {
      print("Error adding user: $error");
      return false;
    }
  }



  Future<bool> deleteUser(String login) async {
    String id = state.firstWhere((el) => el.login == login).id;

    bool IsDeleted = false;
    try {
      final url = Uri.https(project_rtdb,
          'users-list/${id}.json');

      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        IsDeleted = false;
      } else if (response.statusCode == 200) {
        IsDeleted = true;
      }
    } catch (e) {
      return false;
    }


    state = state.where((element) => element.login!=login).toList();


    return IsDeleted;
  }

  void signOut(){
    currentUser = null;
  }

  void signIn(String login){
    currentUser = state.firstWhere((element) => element.login==login);
  }
}

final usersProvider =
StateNotifierProvider<UsersNotifier, List<User>>((ref) => UsersNotifier());