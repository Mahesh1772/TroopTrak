import 'package:firebase_project_2/util/text_styles/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';

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
      backgroundColor: Colors.deepPurple.shade100,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 25,
              horizontal: 35,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 350.w,
                    height: 350.h,
                    padding: EdgeInsets.all(10.sp),
                    transformAlignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      //color: Colors.blueGrey.shade800,
                    ),
                    child: Image.asset(
                      'lib/assets/phone_auth/troopTrak_logo.png',
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Enter Phone Number',
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade300,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'For Registration and login',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _phone.text = value;
                      });
                    },
                    cursorColor: Colors.deepPurple,
                    controller: _phone,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.deepPurple,
                        ),
                        hintText: 'Example: 9865 3214',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                        fillColor: Colors.purple.shade50,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: Colors.deepPurple.shade900,
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
                              "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
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
                    height: 20.h,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 65.h,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(16.sp),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            12.r,
                          ),
                          color: Colors.deepPurple,
                        ),
                        child: StyledText(
                          "Login",
                          20.sp,
                          fontWeight: FontWeight.w500,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
