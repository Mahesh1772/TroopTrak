import 'package:firebase_project_2/phone_authentication/provider/auth_provider.dart';
import 'package:firebase_project_2/phone_authentication/widgets/button_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phone = TextEditingController();
  Country selectedCountry = Country(
    phoneCode: "65",
    countryCode: "SG",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Singapore',
    example: "Singapore",
    displayName: "Singapore",
    displayNameNoCountryCode: "SG",
    e164Key: "",
  );
  @override
  Widget build(BuildContext context) {
    _phone.selection = TextSelection.fromPosition(
      TextPosition(offset: _phone.text.length),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 15.h,
                  horizontal: 35.w,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/phone_auth/troopTrak_logo.png',
                        color: Colors.deepPurpleAccent,
                        width: 300.w,
                      ),
                      Text(
                        'Enter Phone Number',
                        style: GoogleFonts.poppins(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade300,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'For Registration and login',
                        style: GoogleFonts.poppins(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            _phone.text = value;
                          });
                        },
                        cursorColor: Colors.deepPurple.shade300,
                        controller: _phone,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.deepPurple.shade300,
                            ),
                            hintText: 'Example: 9865 3214',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            fillColor: Colors.purple.shade50,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 3,
                                color: Colors.deepPurple.shade400,
                              ), //<-- SEE HERE

                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 3,
                                color: Colors.deepPurple.shade900,
                              ), //<-- SEE HERE

                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            prefixIcon: Container(
                              padding: EdgeInsets.all(16.sp),
                              child: InkWell(
                                onTap: () {
                                  showCountryPicker(
                                    context: context,
                                    countryListTheme: CountryListThemeData(
                                        bottomSheetHeight: 600.h),
                                    onSelect: (value) {
                                      setState(() {
                                        selectedCountry = value;
                                      });
                                    },
                                  );
                                },
                                child: Text(
                                  "${selectedCountry.flagEmoji}  +${selectedCountry.phoneCode}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            suffixIcon: _phone.text.length > 7
                                ? Padding(
                                    padding: EdgeInsets.all(8.0.sp),
                                    child: Container(
                                      height: 20.h,
                                      width: 20.w,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green),
                                      child: Icon(
                                        Icons.done,
                                        color: Colors.white,
                                        size: 30.sp,
                                      ),
                                    ),
                                  )
                                : null),
                      ),
                      SizedBox(
                        height: 50.h,
                      ),
                      WrapperButton(
                        label: 'Login',
                        onPressed: () {
                          sendPhoneNumber();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendPhoneNumber() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = _phone.text.trim();
    ap.signInWithPhone(context, '+${selectedCountry.phoneCode}$phoneNumber');
  }
}
