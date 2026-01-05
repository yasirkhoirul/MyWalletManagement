import 'package:module_auth/domain/entities/user.dart';
import 'package:module_auth/domain/repository/auth_repository.dart';

class PostLogin {
  final AuthRepository authRepository;
  const PostLogin(this.authRepository);

  Future<String> execute(User data) async{
    return authRepository.onLogin(data);
  }
}