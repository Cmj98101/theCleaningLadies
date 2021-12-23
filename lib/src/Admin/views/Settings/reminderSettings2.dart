import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:the_cleaning_ladies/src/admin/views/Settings/reminderSettings.dart';
import 'package:the_cleaning_ladies/src/admin/views/Settings/remindersSetting.dart';

// import 'package:flutter_svg/flutter_svg.dart';
class ReminderSettings extends StatefulWidget {
  final Admin admin;
  ReminderSettings({@required this.admin});
  @override
  _ReminderSettingsState createState() => _ReminderSettingsState();
}

class _ReminderSettingsState extends State<ReminderSettings>
    with TickerProviderStateMixin {
  // Widget svgBG = SvgP
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'Reminder Settings',
            style: TextStyle(color: Colors.black),
          ),
          bottom: TabBar(
            labelColor: Color(0xFF3B67BF),
            labelStyle: TextStyle(fontSize: 20),
            indicatorColor: Color(0xFF3B67BF),
            unselectedLabelColor: Color(0xFFAED2F2),
            tabs: [
              Tab(
                text: 'Template',
              ),
              Tab(
                text: 'Reminder',
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            EditReminderTemplate(
              admin: widget.admin,
              client: Client.demo(),
            ),
            RemindersSetting(
              admin: widget.admin,
            )
          ],
        ),
      ),
    );
  }

  Widget reminder() {
    return Tab(
      text: 'Reminder',
    );
  }
}
