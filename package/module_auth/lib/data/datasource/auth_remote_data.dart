import 'package:firebase_auth/firebase_auth.dart';
import 'package:module_auth/data/model/usermodel.dart';
import 'package:module_core/module_core.dart';

abstract class AuthRemoteData {
  Future<String> onLogin(UserModel data);
  Future<String> onLogout();
  Future<String> onSignUp(UserModel data);
}

class AuthRemoteDataImpl implements AuthRemoteData{
  final FirebaseAuth firebaseAuth;
  const AuthRemoteDataImpl(this.firebaseAuth);
  @override
  Future<String> onLogin(UserModel data) async {
    try {
      final response = await firebaseAuth.signInWithEmailAndPassword(email: data.email, password: data.password);
      if(response.user?.displayName == null){
        throw CustomFirebaseException("error akun tidak ditemukan");
      }
      return response.user!.displayName!;
    } catch (e){
      throw CustomFirebaseException(e);
    }
  }
  
  @override
  Future<String> onLogout()async {
    try {
      await firebaseAuth.signOut();
      return "Logout Sukses";
    }catch(e){
      throw CustomFirebaseException(e);
    }
  }
  
  @override
  Future<String> onSignUp(UserModel data)async {
    try {
      final response = await firebaseAuth.createUserWithEmailAndPassword(email: data.email, password: data.password);
      if(response.user== null){
        throw CustomFirebaseException("terjadi kesalahan");
      }
      return response.user!.displayName!;
    } catch (e) {
      throw CustomFirebaseException(e);
    }
  }

}