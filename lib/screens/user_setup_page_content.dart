import 'package:cupertino_radio_choice/cupertino_radio_choice.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:first_project/model/countries_data.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/screens/auth_gate.dart';
import 'package:first_project/screens/eula_screen.dart';
import 'package:first_project/screens/homepage.dart';
import 'package:first_project/screens/profile_photo_picker_content.dart';
import 'package:first_project/screens/taken_from_firebaseui/email_auth_provider_firebaseUI.dart';
import 'package:first_project/screens/user_setup_page_content.dart';
import 'package:first_project/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/widgets.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

// class UserSetupPage extends StatefulWidget {
//   @override
//   _UserSetupPageState createState() => _UserSetupPageState();
// }

// class _UserSetupPageState extends State<UserSetupPage> {
//   String? _selectedCountry;
//   late String _selectedGender;
//   late TextEditingController _nameController;
//   ValueNotifier<bool> _isButtonVisible = ValueNotifier<bool>(false);

//   @override
//   void initState() {
//     super.initState();
//     _selectedGender = 'm';
//     _nameController = TextEditingController();
//     _nameController.addListener(_checkButtonVisibility);
//   }

//   @override
//   void dispose() {
//     _nameController.removeListener(_checkButtonVisibility);
//     _nameController.dispose();
//     _isButtonVisible.dispose();
//     super.dispose();
//   }

//   void onGenderSelected(String genderKey) {
//     setState(() {
//       _selectedGender = genderKey;
//     });
//   }

//   void onCountrySelected(String country) {
//     setState(() {
//       String emojiFlag = country.characters.first;
//       final Map<String, String> emojiToCountry = allcountries.emojiToCountry;

//       if (emojiToCountry.containsKey(emojiFlag)) {
//         _selectedCountry = emojiToCountry[emojiFlag];
//       } else {
//         _selectedCountry = country;
//       }
//     });
//   }

//   void _checkButtonVisibility() {
//     _isButtonVisible.value = _nameController.text.isNotEmpty;
//     print("is button tapped is " + _isButtonVisible.value.toString());
//   }

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);

//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 25),
//                 Center(
//                   child: Text(
//                     'About You',
//                     style: TextStyle(
//                       fontSize: getProportionateScreenWidth(35),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 50),
//                 Center(
//                   child: Text(
//                     'We will use this information to better tailor your listening experience',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: getProportionateScreenWidth(16),
//                       color: Colors.green.shade300,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 50),
//                 Center(
//                   child: Text(
//                     'Name (required)',
//                     style: TextStyle(
//                       fontSize: getProportionateScreenWidth(25),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 Center(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                     child: TextField(
//                       cursorColor: Colors.green,
//                       controller: _nameController,
//                       decoration: const InputDecoration(
//                         floatingLabelStyle: TextStyle(color: Colors.green),
//                         border: OutlineInputBorder(),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                             color: Colors.green,
//                             width: 2.0,
//                           ),
//                         ),
//                         hintText: 'Enter your name',
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 50),
//                 Center(
//                   child: Text(
//                     'Gender (optional)',
//                     style: TextStyle(
//                       fontSize: getProportionateScreenWidth(25),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 Center(
//                   child: GenderChoiceChip(onGenderSelected: onGenderSelected),
//                 ),
//                 const SizedBox(height: 50),
//                 Center(
//                   child: Text(
//                     'Country (optional)',
//                     style: TextStyle(
//                       fontSize: getProportionateScreenWidth(25),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 Center(
//                   child: CountryDropdownMenu(onCountrySelected: onCountrySelected),
//                 ),
//                 const SizedBox(height: 50),
//                 ValueListenableBuilder<bool>(
//                   valueListenable: _isButtonVisible,
//                   builder: (context, isButtonVisible, child) {
//                     return isButtonVisible
//                         ? Center(
//                             child: ElevatedButton(
//                               style: ButtonStyle(
//                                 backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
//                                 foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
//                                 padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
//                                   const EdgeInsets.all(16.0),
//                                 ),
//                                 textStyle: MaterialStateProperty.all<TextStyle>(
//                                   TextStyle(
//                                     fontSize: getProportionateScreenWidth(20),
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               onPressed: () {
//                                 QawlUser.updateCountry(_selectedCountry ?? ""); // Pass "" if _selectedCountry is null
//                                 QawlUser.updateGender(_selectedGender);
//                                 QawlUser.updateName(_nameController.text);
//                                 Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(builder: (context) => const HomePage()),
//                                 );
//                               },
//                               child: const Text('Next'),
//                             ),
//                           )
//                         : SizedBox.shrink();
//                   },
//                 ),
//                 const SizedBox(height: 25),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class UserSetupPage extends StatefulWidget {
  @override
  _UserSetupPageState createState() => _UserSetupPageState();
}

class _UserSetupPageState extends State<UserSetupPage> {
  String? _selectedCountry;
  late String _selectedGender;
  late TextEditingController _nameController;
  bool _isButtonVisible = false;
  bool _isChecked = false; // Checkbox state

  @override
  void initState() {
    super.initState();
    _selectedGender = 'm';
    _nameController = TextEditingController();
    _nameController.addListener(_checkButtonVisibility);
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkButtonVisibility);
    _nameController.dispose();
    super.dispose();
  }

  void onGenderSelected(String genderKey) {
    setState(() {
      _selectedGender = genderKey;
    });
  }

  void onCountrySelected(String country) {
    setState(() {
      String emojiFlag = country.characters.first;
      final Map<String, String> emojiToCountry = allcountries.emojiToCountry;

      if (emojiToCountry.containsKey(emojiFlag)) {
        _selectedCountry = emojiToCountry[emojiFlag];
      } else {
        _selectedCountry = country;
      }
    });
  }

  void _checkButtonVisibility() {
    setState(() {
      _isButtonVisible = _isChecked;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: Center(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Center(
                    child: Text(
                      'About You',
                      style: TextStyle(
                        fontSize: getProportionateScreenWidth(35),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'We will use this information to better tailor your listening experience',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: getProportionateScreenWidth(16),
                        color: Colors.green.shade300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Center(
                    child: Text(
                      'Name (optional)',
                      style: TextStyle(
                        fontSize: getProportionateScreenWidth(25),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        cursorColor: Colors.green,
                        controller: _nameController,
                        decoration: const InputDecoration(
                          floatingLabelStyle: TextStyle(color: Colors.green),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 2.0,
                            ),
                          ),
                          hintText: 'Enter your name',
                        ),
                        onChanged: (text) {
                          _checkButtonVisibility();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Center(
                    child: Text(
                      'Gender (optional)',
                      style: TextStyle(
                        fontSize: getProportionateScreenWidth(25),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: GenderChoiceChip(onGenderSelected: onGenderSelected),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'Country (optional)',
                      style: TextStyle(
                        fontSize: getProportionateScreenWidth(25),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: CountryDropdownMenu(
                        onCountrySelected: onCountrySelected),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Please scroll through, read and accept the terms and conditions to proceed.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 200.0, // Adjust height as needed
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: Text(eulaText),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Checkbox(
                        checkColor: Colors.white,
                        activeColor: Colors.green,
                        value: _isChecked,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _isChecked = newValue ?? false;
                            _checkButtonVisibility();
                          });
                        },
                      ),
                      const SizedBox(height: 5),
                      const Expanded(
                        child: Text(
                          'I have read the EULA and agree to the terms',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  if (_isButtonVisible)
                    Center(
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.all(16.0),
                          ),
                          textStyle: MaterialStateProperty.all<TextStyle>(
                            TextStyle(
                              fontSize: getProportionateScreenWidth(20),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onPressed: () {
                          QawlUser.updateCountry(_selectedCountry ??
                              ""); // Pass "" if _selectedCountry is null
                          QawlUser.updateGender(_selectedGender);
                          QawlUser.updateName(
                              (_nameController.text?.isEmpty ?? true)
                                  ? "Qawl User"
                                  : _nameController.text);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()),
                          );
                        },
                        child: const Text('Next'),
                      ),
                    ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButtonFormField<String>(
        hint: const Text("Select a country"),
        decoration: const InputDecoration(
          filled: true,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.green,
              width: 2.0,
            ),
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        ),
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
