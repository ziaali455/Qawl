import 'package:cupertino_radio_choice/cupertino_radio_choice.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:first_project/model/countries_data.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/screens/homepage.dart';
import 'package:first_project/screens/taken_from_firebaseui/email_auth_provider_firebaseUI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/widgets.dart';

import 'taken_from_firebaseui/sign_in_screen_firebaseui.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  void _checkUserSignInStatus(User? user) {
    if (user != null) {
      QawlUser.createQawlUser(user);
      print("User has signed in with UID: ${user.uid}");
    } else {
      // User is not signed in or has signed out
      print("User is not signed in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        _checkUserSignInStatus(snapshot.data);

        if (!snapshot.hasData) {
          return MySignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Sign in')
                    : const Text('Register'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.green),
                ),
              );
            },
          );
        }
        return const BeforeHomePage();
      },
    );
  }
}

class BeforeHomePage extends StatelessWidget {
  const BeforeHomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QawlUser?>(
        future: QawlUser.getCurrentQawlUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final gender = snapshot.data?.gender;
            final country = snapshot.data?.country;
            if (gender == null || gender.isEmpty || country == null || country.isEmpty ) {
              return UserSetupPage();
            } else {
              return const HomePage();
            }
          }
        },
      ),
    );
  }
}

class UserSetupPage extends StatefulWidget {
  @override
  _UserSetupPageState createState() => _UserSetupPageState();
}

class _UserSetupPageState extends State<UserSetupPage> {
  String? _selectedCountry;
  late String _selectedGender;
  void initState() {
    super.initState();
    _selectedGender = ""; // Ensure gender is not selected on startup
  }

  void onGenderSelected(String genderKey) {
    setState(() {
      _selectedGender = genderKey;
      print(_selectedGender);
      _checkButtonVisibility();
    });
  }

  void onCountrySelected(String country) {
    setState(() {
      // Extract the first character which represents the emoji flag
      String emojiFlag = country.characters.first;

      // Map of emoji flags to country names
      final Map<String, String> emojiToCountry = allcountries.emojiToCountry;
      print("The flag is " + emojiFlag!);
      // Check if the selected country is an emoji flag
      if (emojiToCountry.containsKey(emojiFlag)) {
        // If it is, set _selectedCountry to its corresponding country name
        _selectedCountry = emojiToCountry[emojiFlag];
        print("The value for DB is " + _selectedCountry!);
      } else {
        // If not, set _selectedCountry directly
        _selectedCountry = country;
      }

      // Check the button visibility
      _checkButtonVisibility();
    });
  }

  void _checkButtonVisibility() {
    setState(() {
      _isButtonTapped = _selectedCountry != null && _selectedGender != null;
    });
  }

  bool _isButtonTapped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            const Text(
              'About You',
              style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'We will use this information to better tailor your listening experience',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                const Text(
                  'Gender',
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoRadioChoice(
                        selectedColor: Colors.green,
                        choices: {'m': '👨🏾‍🦱', 'f': '🧕🏽'},
                        onChange: onGenderSelected,
                        initialKeyValue: 'm')
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      CountryDropdownMenu(onCountrySelected: onCountrySelected),
                ),
                const SizedBox(
                  height: 50,
                ),
                if (_isButtonTapped)
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.green), // Green background
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.white), // White text
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.all(
                              16.0)), // Increase padding to make the button bigger
                      textStyle:
                          MaterialStateProperty.all<TextStyle>(const TextStyle(
                        fontSize: 20, // Increase font size
                        fontWeight: FontWeight.bold, // Bold text
                      )),
                    ),
                    onPressed: () {
                      QawlUser.updateCountry(_selectedCountry!);
                      QawlUser.updateGender(_selectedGender);

                      print(_selectedCountry);
                      print(_selectedGender);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    },
                    child: const Text('Next'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CountryDropdownMenu extends StatefulWidget {
  final void Function(String) onCountrySelected;
  final String? selectedCountry;

  const CountryDropdownMenu({
    Key? key,
    required this.onCountrySelected,
    this.selectedCountry,
  }) : super(key: key);

  @override
  _CountryDropdownMenuState createState() => _CountryDropdownMenuState();
}

class _CountryDropdownMenuState extends State<CountryDropdownMenu> {
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.selectedCountry;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Replace this with your dropdown menu implementation
      child: DropdownButton<String>(
        hint: const Text('Select Country'),
        value: _selectedCountry,
        onChanged: (String? newValue) {
          setState(() {
            _selectedCountry = newValue;
          });
          widget.onCountrySelected(newValue!);
        },
        items: allcountries.countries_new
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}

class CupertinoRadioChoice extends StatefulWidget {
  /// CupertinoRadioChoice displays a radio choice widget with cupertino format
  CupertinoRadioChoice(
      {required this.choices,
      required this.onChange,
      required this.initialKeyValue,
      this.selectedColor = CupertinoColors.systemBlue,
      this.notSelectedColor = CupertinoColors.inactiveGray,
      this.enabled = true});

  /// Function is called if the user selects another choice
  final Function onChange;

  /// Defines which choice shall be selected initally by key
  final dynamic initialKeyValue;

  /// Contains a map which defines which choices shall be displayed (key => value).
  /// Values are the values displyed in the choices
  final Map<dynamic, String> choices;

  /// The color of the selected radio choice
  final Color selectedColor;

  /// The color of the not selected radio choice(s)
  final Color notSelectedColor;

  /// Defines if the widget shall be enabled (clickable) or not
  final bool enabled;

  @override
  _CupertinoRadioChoiceState createState() => new _CupertinoRadioChoiceState();
}

/// State of the widget
class _CupertinoRadioChoiceState extends State<CupertinoRadioChoice> {
  dynamic _selectedKey;

  @override
  void initState() {
    super.initState();
    if (widget.choices.keys.contains(widget.initialKeyValue))
      _selectedKey = widget.initialKeyValue;
    else
      _selectedKey = widget.choices.keys.first;
  }

  Widget buildSelectionButton(String key, String value,
      {bool selected = false}) {
    return Container(
        child: CupertinoButton(
            minSize: 100,
            disabledColor:
                selected ? widget.selectedColor : widget.notSelectedColor,
            color: selected ? widget.selectedColor : widget.notSelectedColor,
            padding: const EdgeInsets.all(10.0),
            child: Text(
              value,
              style: const TextStyle(fontSize: 50),
            ),
            onPressed: !widget.enabled || selected
                ? null
                : () {
                    setState(() {
                      _selectedKey = key;
                    });

                    widget.onChange(_selectedKey);
                  }));
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> buttonList = [];
    for (var key in widget.choices.keys) {
      buttonList.add(buildSelectionButton(key, widget.choices[key]!,
          selected: _selectedKey == key));
    }
    return Wrap(
      children: buttonList,
      spacing: 10.0,
      runSpacing: 5.0,
    );
  }
}
