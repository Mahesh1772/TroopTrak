import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project_2/phone_authentication/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _userid;
  String? get userid => _userid;

  Map<String, dynamic>? _data;
  Map<String, dynamic> get data => _data!;

  final firebase_auth = FirebaseAuth.instance;
  final firebase_store = FirebaseFirestore.instance.collection('Men');

  AuthProvider() {
    checkSignIn();
  }

  void checkSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool('is_signedin') ?? false;
    notifyListeners();
  }

  void setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool('is_signedin', true);
    _isSignedIn = true;
    notifyListeners();
  }

  //Sign in with phone no.
  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await firebase_auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (phoneAuthCredential) async {
          await firebase_auth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          throw Exception(error.message);
        },
        codeSent: (verificationId, forceResendingToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      IconSnackBar.show(
          direction: DismissDirection.horizontal,
          context: context,
          snackBarType: SnackBarType.fail,
          label: e.message.toString(),
          snackBarStyle: const SnackBarStyle());
    }
  }

// verify OTP
  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String otp,
    required Function onsuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp);
      User? user = (await firebase_auth.signInWithCredential(creds)).user!;
      // ignore: unnecessary_null_comparison
      if (user != null) {
        _userid = user.uid;
        onsuccess();
      }
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      IconSnackBar.show(
          duration: const Duration(seconds: 2),
          direction: DismissDirection.horizontal,
          context: context,
          snackBarType: SnackBarType.save,
          label: e.message.toString(),
          snackBarStyle: const SnackBarStyle() // this one
          );
      _isLoading = false;
      notifyListeners();
    }
  }

//ALL DATABASER OPERATIONS
  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot = await firebase_store.doc(_userid).get();
    if (snapshot.exists) {
      print('User Exists');
      return true;
    } else {
      print('New User');
      return false;
    }
  }

  Future<void> saveUserData(
    BuildContext context,
    String name,
    String section,
    String platoon,
    String company,
    String appointment,
    String dob,
    String ord,
    String enlistment,
    String rationType,
    String bloodgroup,
    double points,
    String rank,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      //uploading documents
      await firebase_store.doc(_userid).set({
        //User map formatting
        'rank': rank,
        'name': name,
        'company': company,
        'platoon': platoon,
        'section': section,
        'appointment': appointment,
        'rationType': rationType,
        'bloodgroup': bloodgroup,
        'dob': dob,
        'ord': ord,
        'enlistment': enlistment,
        'points': 0,
        'QRid': null,
      }).then((value) {
        _isLoading = false;
        notifyListeners();
      });
      var Dname = firebase_auth.currentUser!;
      Dname.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      IconSnackBar.show(
          direction: DismissDirection.horizontal,
          context: context,
          snackBarType: SnackBarType.alert,
          label: e.message.toString(),
          snackBarStyle: const SnackBarStyle() // this one
          );
      _isLoading = false;
      notifyListeners();
    }
  }

  Future userSignOut() async {
    await firebase_auth.signOut();
    _isSignedIn = false;
    notifyListeners();
  }

  Future getUserData() async {
    await firebase_store
        .doc(firebase_auth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      _data = snapshot.data() as Map<String, dynamic>;
      _userid = firebase_auth.currentUser!.uid;
    });
  }
}
