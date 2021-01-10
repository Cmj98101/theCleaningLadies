import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/utils/ui_utils/ui/sizing_info.dart';
import 'package:the_cleaning_ladies/utils/ui_utils/ui_utils.dart';

class BaseWidget extends StatelessWidget {
  final Widget Function(BuildContext context, SizingInfo sizingInfo) builder;

  const BaseWidget({Key key, this.builder}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      SizingInfo sizingInfo = SizingInfo(
          orientation: mediaQuery.orientation,
          deviceScreenType: getDeviceType(mediaQuery),
          screenSize: mediaQuery.size,
          localWidgetSize: Size(constraints.maxWidth, constraints.maxHeight));

      return builder(context, sizingInfo);
    });
  }
}
