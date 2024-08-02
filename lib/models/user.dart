class User{

  User({
    required this.id,
    required this.isAdmin,
    required this.login,
    required this.password,
    
  });

  final bool isAdmin;
  final String id;
  final String login;
  final String password;
}