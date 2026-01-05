import 'package:module_auth/domain/repository/auth_repository.dart';

class PostLogout {
  final AuthRepository authRepository;
  const PostLogout(this.authRepository);

  Future<void> execute()async{
    return authRepository.onLogout();
  }
}