import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/service/service.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/src/admin/views/Settings/my_services/add_service.dart';

class MyServices extends StatefulWidget {
  final Admin admin;
  MyServices({
    @required this.admin,
  });
  @override
  _MyServicesState createState() => _MyServicesState();
}

class _MyServicesState extends State<MyServices> {
  List<Service> services = [];
  bool selectingMutiple = true;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddService(admin: widget.admin)));
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('My Services'),
      ),
      body: Column(
        children: [
          // widget.returnService ? Container(
          //   child: CheckboxListTile(
          //     onChanged: (val) {
          //       setState(() {
          //         selectingMutiple = val;
          //       });
          //     },
          //     value: selectingMutiple,
          //     title: Text('Selecting More than one?'),
          //   ),
          // ): Container,
          // !selectingMutiple
          //     ? Container()
          //     : Container(
          //         child: RaisedButton(
          //           onPressed: () {
          //             if (services.isEmpty) {
          //               print('Services array is empty');
          //               assert(services.isNotEmpty);
          //               return;
          //             }
          //             var noDuplicates = [
          //               ...{...services}
          //             ];
          //             services.clear();
          //             // noDuplicates.forEach((service) {
          //             //   print('before: ' + service.name);
          //             // });
          //             Navigator.pop(context, noDuplicates);
          //           },
          //           child: Text('Done'),
          //         ),
          //       ),
          Container(
            height: SizeConfig.safeBlockVertical * 80,
            child: StreamBuilder(
              stream: widget.admin.services.toList,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Service>> snap) {
                switch (snap.connectionState) {
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                    break;

                  default:
                    return snap.hasData
                        ? snap.data.isEmpty
                            ? Container(
                                alignment: Alignment.center,
                                child: Text(
                                    'You do not have any Services Listed!'),
                              )
                            : Container(
                                child: ListView(
                                  children: snap.data.map((service) {
                                    return Container(
                                      child: ServiceTile(
                                        service: service,
                                        onlyShowing: true,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                        : Center(
                            child: CircularProgressIndicator(),
                          );
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceTile extends StatelessWidget {
  final Service service;
  final bool onlyShowing;

  ServiceTile({@required this.service, this.onlyShowing = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        color: onlyShowing
            ? Colors.white
            : service.selected
                ? Colors.green
                : Colors.white,
        elevation: 4,
        child: Container(
          margin: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    alignment: Alignment.center,
                    child: Text(service.name),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                        'Duration: ' + service.duration.inMinutes.toString()),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: Text('Cost: ' + service.cost.toString()),
                  ),
                ],
              ),
              !onlyShowing
                  ? Container()
                  : IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        service.ref.delete();
                      })
            ],
          ),
        ),
      ),
    );
  }
}
