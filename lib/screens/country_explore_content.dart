import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/model/countries_data.dart';
import 'package:first_project/model/user.dart';
import 'package:first_project/screens/now_playing_content.dart';
import 'package:first_project/screens/qari_nation_content.dart';
import 'package:first_project/size_config.dart';
import 'package:first_project/widgets/qawl_back_button_widget.dart';
import 'package:flutter/material.dart';

import '../neu_box.dart';

import 'package:flutter/material.dart';

class CountryExploreContent extends StatefulWidget {
  const CountryExploreContent({Key? key}) : super(key: key);

  @override
  _CountryExploreContentState createState() => _CountryExploreContentState();
}

class _CountryExploreContentState extends State<CountryExploreContent> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: QawlBackButton(),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: List.generate(allcountries.countries.length, (index) {
                return GestureDetector(
                  onTap: () {
                    // print("Passing in " +
                    //     allcountries.countries[index]["countryName"] +
                    //     " and " +
                    //     allcountries.countries[index]["countryName"]);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QariNationContent(
                            allcountries.countries[index]["countryName"]),
                      ),
                    );
                  },
                  child: Container(
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            allcountries.countries[index]["emoji"],
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            allcountries.countries[index]["countryName"],
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// Define a blank page widget
class BlankPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Country Details'), // Example title for the blank page
      ),
      body: Center(
        child:
            Text('Details about the selected country'), // Placeholder content
      ),
    );
  }
}
