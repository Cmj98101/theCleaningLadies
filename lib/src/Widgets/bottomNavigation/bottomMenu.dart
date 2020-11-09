import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/src/sizeConfig.dart';

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
  BottomNav(this.items, {this.onChange});
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
          Container(
            // color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.items.map((item) {
                return displayItem(item);
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget displayItem(MenuItem item) {
    // print(MediaQuery.of(context).size.aspectRatio);
    return Container(
      // width: 100,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            bottom: 0,
            child: Icon(
              item.icon,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: AspectRatio(
              aspectRatio: MediaQuery.of(context).size.aspectRatio,
              child: Container(),
            ),
            onTap: () {
              active = item;
              widget.onChange(item.index);
            },
          ),
        ],
      ),
    );
  }
}
