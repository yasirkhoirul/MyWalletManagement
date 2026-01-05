import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String username;
  final String password;
  final String? email;
  final String? phone;
  const User(this.username,this.password, {this.email, this.phone});
  
  @override
  List<Object?> get props => [username,password,email,phone];
}