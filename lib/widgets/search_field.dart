import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';

class SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchField({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Container(
        width: SizeConfig.screenWidth,
        decoration: BoxDecoration(
          color: kSecondaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          cursorColor: Colors.green,
          onChanged: onChanged,
          decoration: InputDecoration(
              prefixIconColor: Colors.green,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(5),
                  vertical: getProportionateScreenWidth(20)),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              hintText: "Search reciters and uploads",
              prefixIcon: const Icon(Icons.search)),
        ),
      ),
    );
  }
}
