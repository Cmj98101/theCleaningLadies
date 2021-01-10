import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/utils/device_screen_type.dart';

DeviceScreenType getDeviceType(MediaQueryData mediaQuery) {
  Orientation orientation = mediaQuery.orientation;

  double deviceWidth = 0.0;

  if (orientation == Orientation.landscape) {
    deviceWidth = mediaQuery.size.height;
  } else {
    deviceWidth = mediaQuery.size.width;
  }

  if (deviceWidth > 950) {
    return DeviceScreenType.Desktop;
  }
  if (deviceWidth > 600) {
    return DeviceScreenType.Tablet;
  }

  return DeviceScreenType.Mobile;
}
