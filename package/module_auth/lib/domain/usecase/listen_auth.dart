import 'package:module_auth/domain/repository/auth_repository.dart';

class ListenAuth {
  final AuthRepository authRepository;
  const ListenAuth(this.authRepository);

  Stream execute(){
    return authRepository.onListenAuth();
  }
}