import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';

class CustomButtonWithAlert extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;
  final bool useIcon;
  final Widget child;
  final IconData icon;
  final double size;
  CustomButtonWithAlert(
      {this.title,
      this.content,
      this.actions,
      this.icon,
      this.useIcon = true,
      this.child,
      this.size});
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: Text(title), content: Text(content), actions: actions),
      ),
      child: useIcon
          ? Icon(
              icon,
              size: size != null ? size : SizeConfig.safeBlockHorizontal * 7,
            )
          : child,
    );
  }
}
