/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:newsroom/loginScreen.dart';
import 'package:newsroom/registrationScreen.dart';

// Providers for managing state

final passwordVisibilityProvider = StateProvider<bool>((ref) => true);
final usernameProvider = StateProvider<String>((ref) => '');
final mobileNumberProvider = StateProvider<String>((ref) => '');
final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final loadingProvider = StateProvider<bool>((ref) => false); // To handle loading state
final formErrorProvider = StateProvider<String?>((ref) => null); // For storing form error messages

class RegistrationScreen extends ConsumerWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(emailProvider);
    final password = ref.watch(passwordProvider);
    final formError = ref.watch(formErrorProvider);
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);
    final username = ref.watch(usernameProvider);
    final mobileNumber = ref.watch(mobileNumberProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: 80.h, right: 30.r, left: 30.r),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(image: AssetImage("assets/images/logo.png")),
                SizedBox(height: 50.h),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onChanged: (value) => ref.read(usernameProvider.notifier).state = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  decoration: InputDecoration(

                    hintText: "Phone Number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^[+]*[(]{0,1}[6-9]{1,4}[)]{0,1}[-\s0-9]*$'),
                    ),
                  ],
                  validator: (value) {
                    if (value?.length != 10) {
                      return 'Please Enter your PhoneNumber';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  onChanged: (value) => ref.read(mobileNumberProvider.notifier).state = value,

                ),
                SizedBox(height: 20.h),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onChanged: (value) => ref.read(emailProvider.notifier).state = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+\$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        // Toggle password visibility
                        ref.read(passwordVisibilityProvider.notifier).state = !isPasswordVisible;
                      },
                    ),
                  ),
                  obscureText: isPasswordVisible,
                  onChanged: (value) => ref.read(passwordProvider.notifier).state = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                if (formError != null) ...[
                  Text(
                    formError,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                SizedBox(height: 16.h),
                myButton(
                  text: 'Sign up ',
                  onTap: () async {
                    print("SIGNUP>>>>");
                    if (_validateForm(ref)) {
                      await
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sign Up successful!'),),
                      );
                    }
                  },
                  Color: Colors.blue,
                  textcolor: Colors.white,
                  height: 50.0.h,
                  width: 340.0.w,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text("Login"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _validateForm(WidgetRef ref) {
    final email = ref.read(emailProvider).trim();  // Trim the email to remove any leading/trailing spaces
    final password = ref.read(passwordProvider);
    final username = ref.read(usernameProvider);
    final mobileNumber = ref.read(mobileNumberProvider);
    String? error;

    print("Validating email>>>> '$email'");  // Log email to inspect if it has any extra spaces or characters

    if (username.isEmpty) {
      error = 'Username cannot be empty';
    } else if (mobileNumber.isEmpty) {
      error = 'Mobile number cannot be empty';
    } else if (!RegExp(r'^[+]*[(]{0,1}[6-9]{1,4}[)]{0,1}[-\s0-9]*$').hasMatch(mobileNumber)) {
      error = 'Invalid mobile number format';
    } else if (email.isEmpty) {
      error = 'Email cannot be empty';
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      error = 'Invalid email format';
    } else if (password.isEmpty) {
      error = 'Password cannot be empty';
    } else if (password.length < 6) {
      error = 'Password must be at least 6 characters';
    }

    ref.read(formErrorProvider.notifier).state = error;
    return error == null;
  }

  // Sign-up method using Riverpod and Firebase Authentication
  Future<void> _signUp(WidgetRef ref, BuildContext context) async {
    final email = ref.read(emailProvider);
    final password = ref.read(passwordProvider);

    // Start loading state
    ref
        .read(loadingProvider.notifier)
        .state = true;

    try {
      // Firebase user creation
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Handle the newly created user (e.g., save to Firestore)
      // You can add your own logic here, like saving the user's information to Firestore.

      print('User signed up: ${userCredential.user?.email}');

      // Navigate to login page after successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      print('Error signing up: $e');

      // Handle different error scenarios
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          ref
              .read(formErrorProvider.notifier)
              .state = 'Email already in use';
        } else {
          ref
              .read(formErrorProvider.notifier)
              .state = 'Error signing up: ${e.message}';
        }
      } else {
        ref
            .read(formErrorProvider.notifier)
            .state = 'Unknown error occurred';
      }

      // Show a toast message for the error
      EasyLoading.showError('Error: ${e.toString()}');
    } finally {
      // Stop loading state
      ref
          .read(loadingProvider.notifier)
          .state = false;
    }
  }

  Widget myButton({
    String? text,
    void Function()? onTap,
    Color? Color,
    Color? textcolor,
    double? height,
    double? width,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height ?? 50.0,
        width: width ?? 150.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color,
        ),
        child: Center(
          child: text == null
              ? const SizedBox()
              : Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textcolor,
            ),
          ),
        ),
      ),
    );
  }}

*/
