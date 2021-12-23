import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/src/admin/views/Settings/find_phone_number.dart';
import 'package:the_cleaning_ladies/widgets/raisedButtonX.dart';

class MyNumbers extends StatefulWidget {
  final Admin admin;
  MyNumbers({@required this.admin});
  @override
  _MyNumbersState createState() => _MyNumbersState();
}

class _MyNumbersState extends State<MyNumbers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Numbers'),
          // actions: [
          //   IconButton(
          //       icon: Icon(Icons.refresh),
          //       onPressed: () {
          //         setState(() {
          //           _getActivePhoneNumbers();
          //         });
          //       })
          // ],
        ),
        body: widget.admin.twilioNumber.isEmpty
            ? Center(
                child: Container(
                  child: Container(
                    child: ElevatedButtonX(
                      colorX: Colors.green[400],
                      onPressedX: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    FindANumber(admin: widget.admin)));
                      },
                      childX: Text('Look for a Number Now!'),
                    ),
                  ),
                ),
              )
            : Container(
                // color: Colors.green,
                // height: 500,
                child: Container(
                child: Card(
                    elevation: 4,
                    child: ListTile(
                      onTap: () {},
                      title: Text(
                        widget.admin.twilioNumber,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    )),
              )));
  }
}
// class MyNumbers extends StatefulWidget {
//   final Admin admin;
//   MyNumbers({@required this.admin});
//   @override
//   _MyNumbersState createState() => _MyNumbersState();
// }

// class _MyNumbersState extends State<MyNumbers> {
//   Future<List<PhoneNumber>> futureGetActivePhoneNumbers;
//   bool isLoadingNumbers = false;

//   @override
//   void initState() {
//     super.initState();
//     futureGetActivePhoneNumbers = _getActivePhoneNumbers();
//   }

//   Future<List<PhoneNumber>> _getActivePhoneNumbers() async {
//     return await widget.admin.getActivePhoneNumbers((isLoading) {
//       setState(() {
//         isLoadingNumbers = isLoading;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Numbers'),
//         actions: [
//           IconButton(
//               icon: Icon(Icons.refresh),
//               onPressed: () {
//                 setState(() {
//                   _getActivePhoneNumbers();
//                 });
//               })
//         ],
//       ),
//       body: Container(
//           child: Container(
//               // color: Colors.green,
//               height: 500,
//               child: isLoadingNumbers
//                   ? Center(
//                       child: CircularProgressIndicator(),
//                     )
//                   : buildFuture(futureGetActivePhoneNumbers, (snap) {
//                       List<PhoneNumber> phoneNumberList = snap.data;

//                       return ListView.builder(
//                         itemBuilder: (BuildContext context, int index) {
//                           PhoneNumber phoneNumber = phoneNumberList[index];
//                           return Container(
//                             child: Card(
//                                 elevation: 4,
//                                 child: ListTile(
//                                   onTap: () {},
//                                   title: Text(
//                                     phoneNumber.friendlyName,
//                                     style:
//                                         TextStyle(fontWeight: FontWeight.w600),
//                                   ),
//                                   subtitle: Text(phoneNumber.pnSID),
//                                 )),
//                           );
//                         },
//                         itemCount: phoneNumberList.length,
//                       );
//                     }))),
//     );
//   }

//   Widget buildFuture(Future future, Widget Function(AsyncSnapshot) widget) {
//     return FutureBuilder(
//         future: future,
//         builder: (BuildContext context, AsyncSnapshot<dynamic> snap) {
//           switch (snap.connectionState) {
//             case ConnectionState.waiting:
//               return Center(
//                 child: Container(
//                   child: CircularProgressIndicator(),
//                 ),
//               );

//               break;

//             case ConnectionState.done:
//               return widget(snap);
//               break;

//             default:
//               return (Container(
//                 child: Text('NA'),
//               ));
//           }
//         });
//   }
// }
