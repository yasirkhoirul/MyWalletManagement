import 'package:module_auth/data/datasource/auth_remote_data.dart';
import 'package:module_auth/data/model/usermodel.dart';
import 'package:module_auth/domain/entities/user.dart';
import 'package:module_auth/domain/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseuser;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteData authRemoteData;
  const AuthRepositoryImpl(this.authRemoteData);
  @override
  Future<String> onLogin(User data) async{
    return await authRemoteData.onLogin(UserModel.fromEntity(data));
  }

  @override
  Future<void> onLogout() async {
    await authRemoteData.onLogout();
  }

  @override
  Future<String> onSignUp(User data) async{
    return await authRemoteData.onSignUp(UserModel.fromEntity(data));
  }
  
  @override
  Stream<firebaseuser.User?> onListenAuth() {
    return authRemoteData.onListenAuth();
  }
  
  @override
  Future<void> onForget(String email) async{
    return await authRemoteData.onForget(email);
  }
}