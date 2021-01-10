import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';

class MenuItem {
  final String name;
  final Color color;
  final IconData icon;
  final double x;
  final int index;
  MenuItem({this.name, this.color, this.icon, this.x, this.index});
}

class BottomNav extends StatefulWidget {
  final Function(dynamic) onChange;
  final List<MenuItem> items;
  final Admin admin;
  BottomNav(this.items, {this.onChange, this.admin});
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  var active;

  @override
  void initState() {
    super.initState();
    active = widget.items[2];
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double w = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.transparent,
      height: 80,
      child: Stack(
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            alignment: Alignment(active.x, -1),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              height: 8,
              width: w * .2,
              color: active.color,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            bottom: 0,
            child: Container(
              // color: Colors.red,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: widget.items.map((item) {
                  return displayItem(item);
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget displayItem(MenuItem item) {
    // print(MediaQuery.of(context).size.aspectRatio);
    return Container(
      width: 50,
      height: 50,
      // color: Colors.green,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            bottom: 0,
            child: Container(
              // alignment: Alignment.center,
              child: Stack(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    child: Icon(
                      item.icon,
                    ),
                  ),
                  item.index == 0 && widget.admin.notificationCount > 0
                      ? Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                widget.admin.notificationCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: AspectRatio(
                aspectRatio: MediaQuery.of(context).size.aspectRatio,
                child: Container(
                    // color: Colors.red,
                    ),
              ),
              onTap: () {
                active = item;
                widget.onChange(item.index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
