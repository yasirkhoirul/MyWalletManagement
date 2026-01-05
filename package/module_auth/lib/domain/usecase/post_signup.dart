import 'package:module_auth/domain/entities/user.dart';
import 'package:module_auth/domain/repository/auth_repository.dart';

class PostSignup {
  final AuthRepository authRepository;
  const PostSignup(this.authRepository);
  Future<String> execute(User data)async{
    return authRepository.onSignUp(data);
  }
}