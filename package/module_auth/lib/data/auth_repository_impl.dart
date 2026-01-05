import 'package:module_auth/data/datasource/auth_remote_data.dart';
import 'package:module_auth/data/model/usermodel.dart';
import 'package:module_auth/domain/entities/user.dart';
import 'package:module_auth/domain/repository/auth_repository.dart';
import 'package:module_auth/domain/entities/auth_user.dart';

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
  Stream<AuthUser?> onListenAuth() {
    return authRemoteData.onListenAuth().map((fbUser) {
      if (fbUser == null) return null;
      try {
        return AuthUser(id: fbUser.uid, email: fbUser.email);
      } catch (_) {
        return null;
      }
    });
  }

  
  @override
  Future<void> onForget(String email) async{
    return await authRemoteData.onForget(email);
  }
}