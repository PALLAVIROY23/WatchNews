import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:newsroom/loginScreen.dart';

final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final loadingProvider = StateProvider<bool>((ref) => false);
final formErrorProvider = StateProvider<String?>((ref) => null);
final passwordVisibilityProvider = StateProvider<bool>((ref) => false); 

class RegistrationScreen extends ConsumerWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(emailProvider);
    final password = ref.watch(passwordProvider);
    final isLoading = ref.watch(loadingProvider);
    final formError = ref.watch(formErrorProvider);
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 150.h),
          child: Column(
            children: [
              const Image(image: AssetImage("assets/images/logo.png")),
              SizedBox(height: 50.h),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onChanged: (value) {
                  ref.read(emailProvider.notifier).state = value;

                  ref.read(formErrorProvider.notifier).state = null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20.h),
              TextField(
                style: const TextStyle(color: Colors.white),
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.white,),
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      ref.read(passwordVisibilityProvider.notifier).state = !isPasswordVisible;
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onChanged: (value) {
                  ref.read(passwordProvider.notifier).state = value;

                  ref.read(formErrorProvider.notifier).state = null;
                },
              ),
              // Error message
              if (formError != null) ...[
                Text(
                  formError,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : myButton(
                text: 'Sign Up',
                onTap: () => _signUp(ref, context),
                Color: const Color(0xff007bc0),
                textcolor: Colors.white,
                height: 50.0.h,
                width: 340.0.w,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an Account?",style: TextStyle(color: Colors.white),),
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

              Image(image: const AssetImage("assets/images/SignUpLogo.png"),height: 250.h,width: 300.w,)
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _signUp(WidgetRef ref, BuildContext context) async {
    final email = ref.read(emailProvider);
    final password = ref.read(passwordProvider);

    // Start loading state
    ref.read(loadingProvider.notifier).state = true;

    if (email.isEmpty || password.isEmpty) {
      ref.read(formErrorProvider.notifier).state = 'Please enter both email and password';
      ref.read(loadingProvider.notifier).state = false;
      return;
    }

    try {

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('User signed up: ${userCredential.user?.email}');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      print('Error signing up: $e');

      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          ref.read(formErrorProvider.notifier).state = 'Email already in use';
        } else {
          ref.read(formErrorProvider.notifier).state = 'Error signing up: ${e.message}';
        }
      } else {
        ref.read(formErrorProvider.notifier).state = 'Unknown error occurred';
      }
      EasyLoading.showError('Error: ${e.toString()}');
    } finally {

      ref.read(loadingProvider.notifier).state = false;
    }
  }
}
