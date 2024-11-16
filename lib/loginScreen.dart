import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:newsroom/HomeScreen.dart';
import 'package:newsroom/registrationScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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
    final isLoading = ref.watch(loadingProvider);


    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 40.w,vertical: 150.h),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(image: AssetImage("assets/images/logo.png")),
                SizedBox(height: 50.h),
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onChanged: (value) => ref.read(emailProvider.notifier).state = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.white,),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {

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
                 SizedBox(height: 20.h),
                isLoading
                    ? const CircularProgressIndicator()
                    : myButton(
                  text: 'Login',
                  onTap: () => _login(context, ref),
                  Color: Color(0xff007bc0),
                  textcolor: Colors.white,
                  height: 50.0.h,
                  width: 340.0.w,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Text("Don't have an account?",style: TextStyle(color: Colors.white),),
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
                ),
                Image(image: AssetImage("assets/images/loginLogo.png"),height: 200.h,width: 200.w,)
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
          MaterialPageRoute(builder: (context) => HomeScreen()), // Replace with actual NewsRoom page
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
