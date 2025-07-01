import 'package:first_project/screens/profile_content.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../model/user.dart';
import '../size_config.dart';

class QariCard extends StatelessWidget {
  const QariCard({
    super.key,
    required this.width,
    required this.user,
  });

  final double width;
  final QawlUser user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(getProportionateScreenWidth(10)),
      child: SizedBox(
        width: getProportionateScreenWidth(width),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfileContent(
                      user: user,
                      isPersonal: false,
                    )),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: .75,
                child: Container(
                  padding: EdgeInsets.all(getProportionateScreenWidth(20)),
                  decoration: BoxDecoration(
                    color: kSecondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Hero(
                        tag: "user",
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.network(
                                  user.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Load default image when loading fails
                                    return Image.network(
                                      'https://firebasestorage.googleapis.com/v0/b/qawl-io-8c4ff.appspot.com/o/images%2Fdefault_images%2FEDA16247-B9AB-43B1-A85B-2A0B890BB4B3_converted.png?alt=media&token=6e7f0344-d88d-4946-a6de-92b19111fee3',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ))),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: getProportionateScreenWidth(17),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
