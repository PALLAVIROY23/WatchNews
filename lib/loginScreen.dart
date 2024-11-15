import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:newsroom/HomeScreen.dart';
import 'package:newsroom/registrationScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
 // Replace with the actual import for your NewsRoom page

// Providers for managing state
final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final formErrorProvider = StateProvider<String?>((ref) => null);
final passwordVisibilityProvider = StateProvider<bool>((ref) => true); // New provider for password visibility
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(emailProvider);
    final password = ref.watch(passwordProvider);
    final formError = ref.watch(formErrorProvider);
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.only(bottom: 80.h, right: 30.r, left: 30.r),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(image: AssetImage("assets/images/logo.png")),
                SizedBox(height: 50.h),
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
                  text: 'Login',
                  onTap: () => _login(context, ref),
                  Color: Colors.blue,
                  textcolor: Colors.white,
                  height: 50.0.h,
                  width: 340.0.w,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(), // Replace with your next screen
                          ),
                        );
                      },
                      child: const Text("Signup"),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login(BuildContext context, WidgetRef ref) async {
    try {
      bool isValid = _formKey.currentState!.validate();
      if (isValid) {
        EasyLoading.show(status: 'Logging in...');
        final email = ref.read(emailProvider);
        final password = ref.read(passwordProvider);

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        EasyLoading.dismiss();

        // Handle the logged-in user (e.g., navigate to home screen)
        String? userEmail = userCredential.user?.email;
        print('User logged in: $userEmail');

        // Store Firebase Authentication ID token in shared preferences
        String? idToken = await userCredential.user?.getIdToken();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (idToken != null) {
          prefs.setString('token', idToken);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homescreen()), // Replace with actual NewsRoom page
        );
      }
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      print('Authentication failed: ${e.code}');
      EasyLoading.showError("Authentication failed: ${e.message}");

      if (e.code == 'user-not-found') {
        EasyLoading.showInfo('Your email is not registered');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegistrationScreen()),
        );
      }
    }
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
}
