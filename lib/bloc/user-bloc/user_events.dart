import 'package:admin_panel_medlab/models/user_model.dart';

abstract class UserEvents {}

class SignIn extends UserEvents {
  final String email;
  final String password;

  SignIn({required this.email, required this.password});
}

class SignUp extends UserEvents {
  final User user;
  final String password;

  SignUp({required this.user, required this.password});
}
