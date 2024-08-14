import 'package:audio_service/audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:first_project/model/audio_handler.dart';
import 'package:first_project/screens/auth_gate.dart';
import 'package:first_project/screens/homepage.dart';

import 'package:first_project/screens/login_content.dart';
import 'package:first_project/screens/own_login_screen.dart';
import 'package:first_project/size_config.dart';



import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';

//sql-like queries that you can call in main()
// void updateGendersToMale() async {
//   try {
//     // Query all documents in the 'QawlUsers' collection
//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//         .collection('QawlUsers')
//         .get();

//     // Iterate through each document and update the gender field to 'm'
//     for (QueryDocumentSnapshot doc in snapshot.docs) {
//       await doc.reference.update({'gender': 'm'});
//     }

//     print('All genders updated to "m" successfully.');
//   } catch (e) {
//     print('Error updating genders: $e');
//   }
// }

// Future<void>main() async {

//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//    // name: 'qawl-io',
//     //options: DefaultFirebaseOptions.currentPlatform,
//   );
//   WidgetsFlutterBinding.ensureInitialized();
//   final audioHandler = await AudioService.init(
//     builder: () => MyAudioHandler(),
//     config: const AudioServiceConfig(
//       androidNotificationChannelId: 'com.example.app.channel.audio',
//       androidNotificationChannelName: 'Audio Playback',
//       androidNotificationOngoing: true,
//     ),
//   );

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {

//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Qawl',
//       debugShowCheckedModeBanner: false,
//       themeMode: ThemeMode.dark,
//       darkTheme: FlexThemeData.dark(
//         scheme: FlexScheme.hippieBlue,
//         darkIsTrueBlack: true,
//       ),
//       home: const AuthGate(),
//     );
//   }

// }

//how to use audio handler elsewhere:
//final audioHandler = Provider.of<AudioHandler>(context);

import 'package:first_project/model/audio_handler.dart'; // Make sure to import your MyAudioHandler

// import 'firebase_options.dart'; // Uncomment and use if you have this file


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  Future<void> main() async {
  // await JustAudioBackground.init(
  //   androidNotificationChannelId: 'com.testing.qawl/audio_session',
  //   androidNotificationChannelName: 'Audio playback',
  //   androidNotificationOngoing: true,
  // );
  runApp(MyApp());
}
  await Firebase.initializeApp(
      name: 'qawl-io', // had to uncomment bc of firebase issues?
      options: DefaultFirebaseOptions.currentPlatform,
      );
  
  final audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.first_project.channel.audio',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
    ),
  );


  runApp(
    MultiProvider(
      providers: [
        Provider<MyAudioHandler>.value(value: audioHandler),
      ],
      child: MyApp(),
    ),
  );
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     return MaterialApp(
//       title: 'Qawl',
//       debugShowCheckedModeBanner: false,
//       themeMode: ThemeMode.dark,
//       theme: ThemeData(fontFamily: 'Cera'),
//       darkTheme: FlexThemeData.dark(
//         scheme: FlexScheme.hippieBlue,
//         darkIsTrueBlack: true,
//       ),
//         // home: const AuthGate(), //*OLD*
//         // make sure to load data only if user is signed in
//         home: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.active) {
//             if (snapshot.hasData) {
//               return HomePage(); // User is logged in
//             } else {
//               return LoginPage(); // User is not logged in
//             }
//           }
//           return CircularProgressIndicator(color: Colors.green); // Waiting for auth state
//         },
//       ),
//     );
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    if (_isLoading) {
      return const SplashScreen();
    }

    return MaterialApp(
      title: 'Qawl',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(fontFamily: 'Cera'),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.hippieBlue,
        darkIsTrueBlack: true,
      ),
      home: _isAuthenticated ? const HomePage() : LoginPage(),
      // home: AuthGate(),
    );
  }
}



class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.purple),
      ),
    );
  }
}
