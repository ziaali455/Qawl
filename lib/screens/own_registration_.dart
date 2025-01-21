// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/own_auth_service.dart';
import 'package:first_project/screens/auth_gate.dart';
import 'package:first_project/screens/homepage.dart';
import 'package:first_project/screens/own_login_screen.dart';
import 'package:first_project/screens/user_setup_page_content.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:google_sign_in/google_sign_in.dart';

// class RegistrationPage extends StatelessWidget {
//   RegistrationPage({super.key});

//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();

//   void registerUser(BuildContext context) async {
//     if (passwordController.text != confirmPasswordController.text) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Passwords do not match")),
//       );
//       return; // Exit if passwords do not match
//     }

//     try {
//       UserCredential userCredential =
//           await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: emailController.text,
//         password: passwordController.text,
//       );
//       await QawlUser.createQawlUser(
//           userCredential.user); // Ensure this is awaited if asynchronous

//       // Navigate based on user details
//       checkUserDetailsAndNavigate(userCredential.user, context);
//     } catch (error) {
//       debugPrint("Registration failed: $error");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Registration failed: $error")),
//       );
//     }
//   }

//   void checkUserDetailsAndNavigate(User? user, BuildContext context) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => FutureBuilder<QawlUser?>(
//           future: QawlUser.getCurrentQawlUser(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                   child: CircularProgressIndicator(color: Colors.green));
//             } else if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             } else {
//               final gender = snapshot.data?.gender;
//               final country = snapshot.data?.country;
//               if (gender == null ||
//                   gender == "" ||
//                   gender.isEmpty ||
//                   country == null ||
//                   country.isEmpty) {

//                 // print("here going to beforehomepage");
//                 return UserSetupPage();
//               } else {
//                 // print("HERE GOING HOME PAGE");
//                 return const HomePage();
//               }
//             }
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     String logoImagePath = 'images/qawl-lime.png';

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 50),
//                   SizedBox(
//                     width: 200.0, // specify the desired width
//                     height: 200.0, // specify the desired height
//                     child: Image.asset(logoImagePath),
//                   ),
//                   const SizedBox(height: 25),
//                   const Text(
//                     'Register on Qawl',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 25),
//                   TextFormField(
//                     controller: emailController,
//                     decoration: const InputDecoration(
//                       labelText: 'Email', hintText: 'Email',
//                       floatingLabelStyle: TextStyle(color: Colors.green),
//                       border: OutlineInputBorder(), // default border
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Colors.green, // set the color to green
//                           width: 2.0, // set the width of the border
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   TextFormField(
//                     controller: passwordController,
//                     obscureText: true,
//                     decoration: const InputDecoration(
//                       labelText: 'Password', hintText: 'Password',
//                       floatingLabelStyle: TextStyle(color: Colors.green),
//                       border: OutlineInputBorder(), // default border
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Colors.green, // set the color to green
//                           width: 2.0, // set the width of the border
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   TextFormField(
//                     controller: confirmPasswordController,
//                     obscureText: true,
//                     decoration: const InputDecoration(
//                       labelText: 'Confirm Password',
//                       hintText: 'Confirm Password',
//                       floatingLabelStyle: TextStyle(color: Colors.green),
//                       border: OutlineInputBorder(), // default border
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                           color: Colors.green, // set the color to green
//                           width: 2.0, // set the width of the border
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 25),
//                   ElevatedButton(
//                     style: const ButtonStyle(
//                       backgroundColor:
//                           WidgetStatePropertyAll<Color>(Colors.green),
//                     ),
//                     onPressed: () => registerUser(context),
//                     child: const Text(
//                       'Create Account',
//                       style:
//                           TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   const SizedBox(height: 50),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         'Already a Qawl User?',
//                         style: TextStyle(
//                           color: Colors.green,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       InkWell(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => LoginPage()),
//                           );
//                         },
//                         child: const Text(
//                           'Log in',
//                           style: TextStyle(
//                             color: Colors.green,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

//   void registerUser(BuildContext context) async {
//   if (passwordController.text == confirmPasswordController.text) {
//     try {
//       UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: emailController.text,
//         password: passwordController.text,
//       );

//       await QawlUser.createQawlUser(userCredential.user!); // Ensure this is awaited if asynchronous
//       debugPrint("User created with UID: ${userCredential.user!.uid}");

//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => const BeforeHomePage()),
//       );
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Registration failed: $error")),
//       );
//     }
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Passwords do not match")),
//     );
//   }
// }

//    void registerUser(BuildContext context) async {
//   if (passwordController.text != confirmPasswordController.text) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Passwords do not match")),
//     );
//     return; // Exit if passwords do not match
//   }

//   try {
//     UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//       email: emailController.text,
//       password: passwordController.text,
//     );
//     await QawlUser.createQawlUser(userCredential.user); // Ensure this is awaited if asynchronous

//     debugPrint("User created with UID: ${userCredential.user?.uid}");
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => UserSetupPage()),
//     );
//   } catch (error) {
//     debugPrint("Registration failed: $error");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Registration failed: $error")),
//     );
//   }
// }

class RegistrationPage extends StatefulWidget {
  RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  void _toggleLoading(bool isLoading) {
    _isLoading.value = isLoading;
  }

  Future<void> registerUser(BuildContext context) async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return; // Exit if passwords do not match
    }

    _toggleLoading(true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      await QawlUser.createQawlUser(
          userCredential.user); // Ensure this is awaited if asynchronous

      // Navigate based on user details
      await AuthService()
          .checkUserDetailsAndNavigate(userCredential.user, context);
    } catch (error) {
      debugPrint("Registration failed: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $error")),
      );
    }

    _toggleLoading(false);
  }

  // Future<void> checkUserDetailsAndNavigate(
  //     User? user, BuildContext context) async {
  //   final currentUser = await QawlUser.getCurrentQawlUser();

  //   if (currentUser == null) {
  //     // Handle error or navigate to error page
  //     return;
  //   }

  //   if (currentUser.gender == null ||
  //       currentUser.gender == "" ||
  //       currentUser.gender.isEmpty ||
  //       currentUser.country == null ||
  //       currentUser.country.isEmpty) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => UserSetupPage()),
  //     );
  //   } else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const HomePage()),
  //     );
  //   }
  // }

  // Future<void> LoginWithGoogle(BuildContext context) async {
  //   try {
  //     _toggleLoading(true); // Start the loading indicator

  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  //     if (googleUser == null) {
  //       _toggleLoading(false);
  //       return;
  //     }

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     final OAuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     UserCredential userCredential =
  //         await FirebaseAuth.instance.signInWithCredential(credential);

  //     final String uid = userCredential.user!.uid;

  //     // check if user exists in firebase already, otherwise create the QawlUser and its collection
  //     final users = FirebaseFirestore.instance.collection('QawlUsers');
  //     final userDoc = await users.doc(uid).get();

  //     if (!userDoc.exists) {
  //       await QawlUser.createQawlUser(userCredential.user);
  //     }
  //     await checkUserDetailsAndNavigate(userCredential.user, context);
  //   } catch (error) {
  //     debugPrint("Google Sign-In failed: $error");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Google Sign-In failed: $error")),
  //     );
  //   } finally {
  //     _toggleLoading(false); // Stop the loading indicator
  //   }
  // }

  // add to ui stuff and make sure sign out works like before
  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    String logoImagePath = 'images/qawl-lime.png';
    String GoogleLogoImagePath = 'assets/google_logo.png';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (context, isLoading, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 25),
                      SizedBox(
                        width: 200.0,
                        height: 200.0,
                        child: Image.asset(logoImagePath),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Register on Qawl',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
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
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Confirm Password',
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
                      const SizedBox(height: 25),
                      isLoading
                          ? CircularProgressIndicator(color: Colors.green)
                          : ElevatedButton(
                              style: const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll<Color>(
                                        Colors.green),
                              ),
                              onPressed: () => registerUser(context),
                              child: const Text(
                                'Create Account',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                      const SizedBox(height: 10),

                      isLoading
                          ? CircularProgressIndicator(color: Colors.green)
                          : SignupWithGoogleWidget(GoogleLogoImagePath: GoogleLogoImagePath),
                      const SizedBox(height: 10),
                      isLoading
                          ? CircularProgressIndicator(color: Colors.green)
                          : SignupWithAppleWidget(AppleLogoImagePath: GoogleLogoImagePath),    
                          
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already a Qawl User?',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            },
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                          height:
                              16), // Space between "Log in" and Google button
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignupWithGoogleWidget extends StatelessWidget {
  const SignupWithGoogleWidget({
    super.key,
    required this.GoogleLogoImagePath,
  });

  final String GoogleLogoImagePath;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AuthService().LoginWithGoogle(context);
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              GoogleLogoImagePath, // Replace with the path to your Google icon asset
              height: 20.0, // Adjust size as needed
              width: 20.0, // Adjust size as needed
            ),
            const SizedBox(width: 8), // Space between icon and text
            const Text(
              'Sign up with Google',
              style: TextStyle(
                color: Colors.black, // Text color
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class SignupWithAppleWidget extends StatelessWidget {
  const SignupWithAppleWidget({
    super.key,
    required this.AppleLogoImagePath,
  });

  final String AppleLogoImagePath;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AuthService().LoginWithApple(context);
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/google_logo.png', // Replace with the path to your Google icon asset
              height: 20.0, // Adjust size as needed
              width: 20.0, // Adjust size as needed
            ),
            const SizedBox(width: 8), // Space between icon and text
            const Text(
              'Sign up with Apple',
              style: TextStyle(
                color: Colors.black, // Text color
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
