import 'package:first_project/model/user.dart';
import 'package:first_project/screens/homepage.dart';
import 'package:first_project/screens/own_forgot_password.dart';
import 'package:first_project/screens/own_registration_.dart';
import 'package:first_project/size_config.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_project/own_auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

// class LoginPage extends StatefulWidget {
//   LoginPage({super.key});

//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   bool _isLoading = true;
//   bool _isAuthenticated = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkAuthState();
//   }

//   Future<void> _checkAuthState() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       setState(() {
//         _isAuthenticated = true;
//         _isLoading = false;
//       });
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) => const HomePage(),
//           ),
//         );
//       });
//     } else {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Center(
//           child: _isLoading
//               ? const CircularProgressIndicator(color: Colors.red)
//               : buildSignInForm(context),
//         ),
//       ),
//     );
//   }

//   Widget buildSignInForm(BuildContext context) {
//     String logoImagePath = 'images/qawl-lime.png';
//     SizeConfig().init(context);
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const SizedBox(height: 25),
//           WidgetAnimator(
//             incomingEffect: WidgetTransitionEffects.incomingSlideInFromTop(),
//             child: SizedBox(
//               width: 200.0,
//               height: 200.0,
//               child: Image.asset(logoImagePath),
//             ),
//           ),
//           const SizedBox(height: 25),
//           Text(
//             'Welcome to Qawl!',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: getProportionateScreenWidth(20),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 25),
//           TextFormField(
//             controller: emailController,
//             decoration: const InputDecoration(
//               labelText: 'Email',
//               hintText: 'Email',
//               floatingLabelStyle: TextStyle(color: Colors.green),
//               border: OutlineInputBorder(),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: Colors.green,
//                   width: 2.0,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           TextFormField(
//             controller: passwordController,
//             obscureText: true,
//             decoration: const InputDecoration(
//               labelText: 'Password',
//               hintText: 'Password',
//               floatingLabelStyle: TextStyle(color: Colors.green),
//               border: OutlineInputBorder(),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: Colors.green,
//                   width: 2.0,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 25.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 GestureDetector(
//                   child: const Text(
//                     'Forgot Password?',
//                     style: TextStyle(
//                       color: Colors.green,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ForgotPasswordPage(),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 25),
//           ElevatedButton(
//             style: const ButtonStyle(
//               backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
//             ),
//             onPressed: () async {
//               final message = await AuthService().login(
//                 email: emailController.text,
//                 password: passwordController.text,
//               );
//               if (message!.contains('Success')) {
//                 Navigator.of(context).pushReplacement(
//                   MaterialPageRoute(
//                     builder: (context) => const HomePage(),
//                   ),
//                 );
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Incorrect email or password provided'),
//                   ),
//                 );
//               }
//             },
//             child: const Text(
//               'Login',
//               style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//             ),
//           ),
//           const SizedBox(height: 50),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'New User?',
//                 style: TextStyle(color: Colors.white),
//               ),
//               const SizedBox(width: 4),
//               InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => RegistrationPage()),
//                   );
//                 },
//                 child: const Text(
//                   'Register now',
//                   style: TextStyle(
//                     color: Colors.green,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  @override
  _LoginPageState createState() => _LoginPageState();
}

// void _toggleLoading(bool isLoading) {
//     _isLoading.value = isLoading;
//   }

class _LoginPageState extends State<LoginPage> {
  // Text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
    // _isLoading.dispose();

  }

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Builder(
        builder: (context) {
          final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 25),
                  WidgetAnimator(
                    incomingEffect: WidgetTransitionEffects.incomingSlideInFromTop(),
                    child: SizedBox(
                      width: 200.0,
                      height: 200.0,
                      child: Image.asset('images/qawl-lime.png'),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Welcome to Qawl!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: getProportionateScreenWidth(20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Email',
                      floatingLabelStyle: TextStyle(color: Colors.green),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Password',
                      floatingLabelStyle: TextStyle(color: Colors.green),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final message = await AuthService().login(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                      if (message!.contains('Success')) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Incorrect email or password provided'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 50), // Add space between the buttons
                   SignInWithGoogleWidget(),
                  const SizedBox(height: 20),
                  SignInWithAppleWidget(),
                  const SizedBox(height: 30), // Spacing before the "New User" section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'New User?',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegistrationPage()),
                          );
                        },
                        child: const Text(
                          'Register now',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (keyboardVisible) SizedBox(height: 80), // Adjust as needed
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

}

class SignInWithGoogleWidget extends StatelessWidget {
  const SignInWithGoogleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, 
        backgroundColor: Colors.white,
        minimumSize: const Size(100, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Image.asset(
        'assets/google_logo.png', // Path to your Google logo asset
        height: 20,
        width: 20,
      ),
      label: const Text(
        'Sign in with Google',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      onPressed: () async {
        // note the LoginWithGoogle method already calls checkDetailsAndNavigate
          String result = await AuthService().LoginWithGoogle(context); 
        if (result.contains('Success')) {
          // Navigator.of(context).pushReplacement(
          //   MaterialPageRoute(
          //     builder: (context) => const HomePage(), 
          //   ),
          // );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Sign-In failed'),
            ),
          );
        }
      },
    );
  }
}
class SignInWithAppleWidget extends StatelessWidget {
  const SignInWithAppleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(221, 57, 54, 54),
        minimumSize: const Size(100, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Image.asset(
        'assets/apple_logo.png', // Path to your Google logo asset
        height: 20,
        width: 20,
      ),
      label: const Text(
        ' Sign in with Apple ',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, ),
      ),
      onPressed: () async {
        // note the LoginWithGoogle method already calls checkDetailsAndNavigate
          String result = await AuthService().LoginWithApple(context); 
        if (result.contains('Success')) {
          // Navigator.of(context).pushReplacement(
          //   MaterialPageRoute(
          //     builder: (context) => const HomePage(), 
          //   ),
          // );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Apple Sign-In failed'),
            ),
          );
        }
      },
    );
  }
}