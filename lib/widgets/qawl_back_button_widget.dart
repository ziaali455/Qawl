import 'package:first_project/neu_box.dart';
import 'package:flutter/material.dart';

class QawlBackButton extends StatelessWidget {
  const QawlBackButton({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only( left: 8.0),
          child: GestureDetector(
            child: const Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                  height: 40,
                  width: 40,
                  child: NeuBox(child: Icon(Icons.arrow_back))),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
