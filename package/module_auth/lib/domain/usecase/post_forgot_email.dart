import 'package:module_auth/domain/repository/auth_repository.dart';

class PostForgotEmail {
  final AuthRepository authRepository;
  const PostForgotEmail(this.authRepository);

  Future<void> execute(String email)async{
    return authRepository.onForget(email);
  }
}