import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';

class CustomIconTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  CustomIconTile({@required this.title, this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        SizeConfig().init(context);

        return Container(
          height: SizeConfig.safeBlockVertical * 10,
          margin: EdgeInsets.only(left: 15, bottom: 5, right: 15),
          child: InkWell(
            onTap: onTap,
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Icon(
                  icon,
                  size: SizeConfig.safeBlockVertical * 6,
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    width: SizeConfig.safeBlockHorizontal * 65,
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Text(
                      title,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
