import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/utils/device_screen_type.dart';

class SizingInfo {
  final Orientation orientation;
  final DeviceScreenType deviceScreenType;
  final Size screenSize;
  final Size localWidgetSize;

  SizingInfo(
      {this.orientation,
      this.deviceScreenType,
      this.screenSize,
      this.localWidgetSize});

  @override
  String toString() =>
      'Orientation: $orientation DeviceType: $deviceScreenType ScreenSize: width - ${screenSize.width} height - ${screenSize.height} localWidgetSize: width - ${localWidgetSize.width} height - ${localWidgetSize.height}';
}
