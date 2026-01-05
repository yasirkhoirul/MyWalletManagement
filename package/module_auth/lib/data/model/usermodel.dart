
import 'package:json_annotation/json_annotation.dart';
import 'package:module_auth/domain/entities/user.dart';

part 'usermodel.g.dart';

@JsonSerializable()
class UserModel{
  final String email;
  final String password;
  const UserModel(this.email,this.password);
  factory UserModel.fromJson(Map<String,dynamic> json)=> _$UserModelFromJson(json);
  Map<String,dynamic> toJson()=> _$UserModelToJson(this);
  User toEntity()=> User(email, password);
  factory UserModel.fromEntity(User data)=> UserModel(data.username, data.password);
}