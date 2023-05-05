import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  //this creates a Firebase instance/object to communicate with backend
  // we can hence use _auth to make use of all of firebases built in features
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // Detecting change in stream between user and firebase
  //Stream<User> get user {
  //  return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  //}

  // sign in anonymously
  Future signInAnon() async {
    try {
      //await as the process takes time
      final result = await _auth.signInAnonymously();
      User? user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in wiht email and password

  //register with email and password

  //sign out

}