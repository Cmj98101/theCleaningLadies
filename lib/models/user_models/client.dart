import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/easy_db/EasyDb.dart';
import 'package:the_cleaning_ladies/models/user_models/user.dart';
import 'package:the_cleaning_ladies/models/history_event.dart';
import 'package:the_cleaning_ladies/models/size_config.dart';

enum ServiceTimePreference { earlyMornings, lateMornings, afternoons, custom }
enum PaymentType { cash, check, quickPay, unknown }
enum ServiceFrequency { weekly, biWeekly, monthly, custom }
enum FavoribleScale { notOkay, isOkay, isPrefered }
enum ServiceDifficulty { easy, medium, hard }

class Day {
  String name;
  FavoribleScale favoribleScale = FavoribleScale.notOkay;
  Map<String, int> days = {
    'Mon.': 1,
    'Tues.': 2,
    'Wed.': 3,
    'Thurs.': 4,
    'Fri.': 5,
    'Sat.': 6,
    'Sun.': 7,
  };
  int get weekDay => days[name];
  Color get color => favoribleScale == FavoribleScale.isOkay
      ? Colors.blue[400]
      : favoribleScale == FavoribleScale.isPrefered
          ? Colors.green[400]
          : Colors.red[400];

  Day({this.name, this.favoribleScale = FavoribleScale.notOkay});

  List<Day> fromDocumentFavorableScale(List<dynamic> favorableDays) {
    List<Day> favorableDaysList = [];
    for (var day in favorableDays) {
      favorableDaysList.add(Day(
          name: day['name'],
          favoribleScale: FavoribleScale.values.firstWhere((favorableScale) {
            return favorableScale.toString() == day['favorableScale'];
          })));
    }
    return favorableDaysList;
  }
}

class Client extends User {
  DateTime customTimePreference;
  String adminUserId;
  String businessCode;
  String note;
  bool keyRequired = false;
  bool active = true;
  double costPerCleaning;
  String contactNumber;

  String templateReminderMsg = '';
  int notificationCount = 0;
  DocumentReference reference;
  FirebaseFirestore db = FirebaseFirestore.instance;
  Service service;
  EasyDB _easyDB = DataBaseRepo();
  List<Day> dayPreferences = [];
  List<User> family = <User>[];
  List<dynamic> templateFillInValues = [];
  // History cleaningHistory = CleaningHistory()
  ServiceFrequency serviceFrequency = ServiceFrequency.weekly;
  ServiceTimePreference serviceTimePreference =
      ServiceTimePreference.earlyMornings;
  // TODO: Implement Service Difficulty
  ServiceDifficulty serviceDifficulty;
  PaymentType paymentType = PaymentType.cash;
  DateTime lastService;
  Map weekDays = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  DateTime get lastServiceDateOnly =>
      DateTime(lastService.year, lastService.month, lastService.day);

  String get formattedLastCleaning =>
      DateFormat('MM/dd/yy').format(lastService);

  List<int> get isPreferedDays => checkDays(FavoribleScale.isPrefered);
  List<int> get okayDays => checkDays(FavoribleScale.isOkay);
  List<int> get notOkayDays => checkDays(FavoribleScale.notOkay);
  String get nextCleaning =>
      DateFormat('MM/dd/yy').format(nextCleaningDate['from']);

  String get formatPhoneNumber {
    String removeParathesis = contactNumber.replaceAll(RegExp(r'(\(|\))'), '');
    return removeParathesis.trim().replaceAll(RegExp(r'(\s)'), '');
  }

  String get nextCleaningWeekDay => weekDays[nextCleaningDate['from'].weekday];

  String get formattedAddress {
    return "$streetAddress $buildingNumber \n$city $state $zipCode";
  }

  String get fullName => '$firstName${lastName.isEmpty ? '' : ','} $lastName';

  String get firstAndLastFormatted =>
      '${firstName ?? ''}${lastName.isEmpty ? '' : ', ${(lastName[0]) ?? ''}.'}';
  String get formattedContactNumber {
    String formattedNumber = '';
    for (int i = 0; i < contactNumber.length; i++) {
      if (i == 0) {
        formattedNumber += contactNumber[i];
        continue;
      }
      if (i == 1) {
        formattedNumber += '${contactNumber[i]} (';
        continue;
      }
      if (i == 4) {
        formattedNumber += '${contactNumber[i]}) ';
        continue;
      }
      if (i == 7) {
        formattedNumber += '${contactNumber[i]}-';
        continue;
      }
      formattedNumber += contactNumber[i];
    }
    return formattedNumber;
  }

  void get handleIsActive {
    EasyDB _db = DataBaseRepo();

    _db.editDocumentData('Users/$id', {'activeForCleaning': !active});
    active = !active;
  }

  String get showServiceFrequencyText {
    switch (serviceFrequency) {
      case ServiceFrequency.weekly:
        return 'Weekly';
        break;
      case ServiceFrequency.biWeekly:
        return 'Bi-Weekly';
        break;
      case ServiceFrequency.monthly:
        return 'Monthly';
        break;
      case ServiceFrequency.custom:
        //TODO: Functionality for Custom Service Frequency
        return 'Custom';
        break;
      default:
        return 'Not Available';
    }
  }

  Icon get showPaymentType {
    switch (paymentType) {
      case PaymentType.cash:
        return Icon(
          FontAwesomeIcons.moneyBillWave,
          color: Colors.green[600],
        );

        break;
      case PaymentType.check:
        return Icon(FontAwesomeIcons.moneyCheck, color: Colors.blue[300]);

        break;
      case PaymentType.quickPay:
        return Icon(
          FontAwesomeIcons.ccVisa,
          color: Colors.black,
        );

        break;
      case PaymentType.unknown:
        return Icon(
          FontAwesomeIcons.questionCircle,
          color: Colors.orange,
        );

        break;
      default:
        return Icon(
          FontAwesomeIcons.questionCircle,
          color: Colors.orange,
        );
    }
  }

  String get showServiceTimePreferenceText {
    switch (serviceTimePreference) {
      case ServiceTimePreference.earlyMornings:
        return 'Early Mornings';
        break;
      case ServiceTimePreference.lateMornings:
        return 'Late Mornings';
        break;
      case ServiceTimePreference.afternoons:
        return 'Afternoons';
        break;
      default:
        return 'Not Available';
    }
  }

  Widget displayDayPreferences(
      {bool withCard = true,
      double sizeMultiplier = 3.0,
      double spaceBetweenText,
      EdgeInsetsGeometry margin,
      fontWeight = FontWeight.normal}) {
    return DisplayDayPreferences(
      withCard: withCard,
      dayPreferences: dayPreferences,
      sizeMultiplier: sizeMultiplier,
      fontWeight: fontWeight,
      margin: margin,
    );
  }

  Client(
      {String firstName,
      String lastName,
      String id,
      String streetAddress,
      String buildingNumber,
      String city,
      String state,
      String zipCode,
      UserType userType,
      DocumentReference ref,
      this.note,
      this.keyRequired,
      this.adminUserId,
      this.businessCode,
      this.active,
      this.dayPreferences,
      this.serviceFrequency = ServiceFrequency.weekly,
      this.serviceTimePreference = ServiceTimePreference.earlyMornings,
      this.paymentType,
      this.lastService,
      this.family,
      this.customTimePreference,
      this.costPerCleaning,
      this.contactNumber,
      this.templateReminderMsg,
      this.templateFillInValues,
      this.reference,
      this.notificationCount,
      this.service})
      : super(
            firstName: firstName,
            lastName: lastName,
            id: id,
            streetAddress: streetAddress,
            buildingNumber: buildingNumber,
            city: city,
            state: state,
            zipCode: zipCode,
            userType: userType,
            ref: ref);

  ServiceFrequency serviceFrequencyFromDoc(DocumentSnapshot document) {
    Map<String, dynamic> doc = document.data();
    return ServiceFrequency.values.firstWhere(
        (freq) => freq.toString() == doc['serviceFrequency'], orElse: () {
      print(doc['serviceFrequency']);
      return ServiceFrequency.weekly;
    });
  }

  List<int> checkDays(FavoribleScale favoribleScale) {
    List<int> list = [];
    dayPreferences.forEach((day) {
      if (day.favoribleScale == favoribleScale) {
        list.add(day.weekDay);
      }
    });
    return list;
  }

  bool landsOnFavoribleDay(DateTime nextCleaning) {
    if (isPreferedDays.isNotEmpty) {
      return true;
    } else if (okayDays.isNotEmpty) {
    } else {}
  }

  Map<String, DateTime> get nextCleaningDate {
    DateTime from;
    DateTime to;
    switch (serviceFrequency) {
      case ServiceFrequency.weekly:
        from = lastService.add(Duration(days: 7));
        to = lastService.add(Duration(days: 7));
        // if(from.weekday )
        return {'from': from, 'to': to};
        break;
      case ServiceFrequency.biWeekly:
        from = lastService.add(Duration(days: 14));
        to = lastService.add(Duration(days: 14));
        return {'from': from, 'to': to};
        break;
      case ServiceFrequency.monthly:
        from = lastService.add(Duration(days: 31));
        to = lastService.add(Duration(days: 31));
        return {'from': from, 'to': to};
        break;
      case ServiceFrequency.custom:
        from = lastService.add(Duration(days: 60));
        to = lastService.add(Duration(days: 60));
        return {'from': from, 'to': to};
        break;
      default:
        return {};
    }
  }

  Appointment calculateTimeForCleaningAndSchedule() {
    Appointment appointment;

    switch (serviceTimePreference) {
      case ServiceTimePreference.earlyMornings:
        appointment = Appointment(
          'Cleaning',
          nextCleaningDate['from'].add(Duration(
            hours: 8,
          )),
          nextCleaningDate['to'].add(Duration(hours: 8, minutes: 45)),
          Colors.green,
          false,
          this,
          keyRequired: keyRequired,
        );
        return appointment;

        break;
      case ServiceTimePreference.lateMornings:
        appointment = Appointment(
            'Cleaning',
            nextCleaningDate['from'].add(Duration(hours: 10, minutes: 15)),
            nextCleaningDate['to'].add(Duration(hours: 11)),
            Colors.green,
            false,
            this,
            keyRequired: keyRequired);
        return appointment;
        break;
      case ServiceTimePreference.afternoons:
        appointment = Appointment(
            'Cleaning',
            nextCleaningDate['from'].add(Duration(hours: 12, minutes: 30)),
            nextCleaningDate['to'].add(Duration(hours: 13, minutes: 15)),
            Colors.green,
            false,
            this,
            keyRequired: keyRequired);
        return appointment;
        break;

      case ServiceTimePreference.custom:
        appointment = Appointment(
            'Cleaning',
            nextCleaningDate['from'].add(Duration(hours: 17, minutes: 30)),
            nextCleaningDate['to'].add(Duration(hours: 18, minutes: 15)),
            Colors.green,
            false,
            this,
            keyRequired: keyRequired);
        return appointment;
      default:
        return Appointment.creationFailure();
    }
  }

  void setLastService(DateTime time, Function() onCompletion) => _easyDB
      .editDocumentData('Users/$id', {'lastCleaning': time}).whenComplete(
          () => onCompletion());

  PaymentType getPaymentType(Map<String, dynamic> doc) =>
      PaymentType.values.firstWhere((paymentType) {
        return paymentType.toString() == doc['paymentType'];
      });

  String get readFrequencyFromDB {
    switch (serviceFrequency.toString()) {
      case 'ServiceFrequency.weekly':
        return 'weekly';
        break;
      case 'ServiceFrequency.biWeekly':
        return 'biWeekly';

        break;
      case 'ServiceFrequency.monthly':
        return 'monthly';

        break;
      case 'ServiceFrequency.custom':
        return 'custom';

        break;
      default:
        return 'Unknown';
    }
  }

  factory Client.fromDocumentSnap(DocumentSnapshot document) {
    Map<String, dynamic> doc = document.data();
    Day day = Day();
    List familyFromDoc = doc['family'];
    List<User> family = [];
    for (var fam in familyFromDoc) {
      family.add(User.family(
          firstName: fam['firstName'],
          lastName: fam['lastName'],
          relation: fam['relation']));
    }
    List<Day> dayPreferenceList =
        (day.fromDocumentFavorableScale(doc['dayPreferences']));
    ServiceFrequency serviceFrequency = ServiceFrequency.values.firstWhere(
        (freq) =>
            (freq.toString() == doc['serviceFrequency']) ??
            ServiceFrequency.weekly, orElse: () {
      print(doc['serviceFrequency']);
      return ServiceFrequency.weekly;
    });
    ServiceTimePreference serviceTimePreference = ServiceTimePreference.values
        .firstWhere((pref) => pref.toString() == doc['serviceTimePreference'],
            orElse: () {
      print(doc['serviceTimePreference']);
      return ServiceTimePreference.earlyMornings;
    });
    PaymentType paymentType = PaymentType.values.firstWhere(
        (paymentType) =>
            paymentType.toString() == (doc['paymentType']) ??
            PaymentType.unknown, orElse: () {
      print(doc['paymentType']);
      return PaymentType.unknown;
    });
    Client client = Client(
        ref: document.reference,
        adminUserId: doc['adminUserId'],
        firstName: doc['firstName'].toString(),
        lastName: doc['lastName'].toString(),
        streetAddress: doc['streetAddress'].toString(),
        buildingNumber: doc['buildingNumber'].toString(),
        city: doc['city'].toString(),
        state: doc['state'].toString(),
        zipCode: doc['zipCode'].toString(),
        active: doc['activeForCleaning'],
        lastService: (doc['lastCleaning'] as Timestamp).toDate(),
        userType: UserType.client,
        serviceFrequency: serviceFrequency,
        serviceTimePreference: serviceTimePreference,
        dayPreferences: dayPreferenceList,
        businessCode: doc['businessCode'],
        keyRequired: doc['keyRequired'],
        note: doc['note'] ?? '',
        paymentType: paymentType,
        id: doc['id'],
        family: family,
        costPerCleaning: (doc['costPerCleaning'] is int)
            ? (doc['costPerCleaning'] as int).toDouble()
            : doc['costPerCleaning'] ?? 0.00,
        contactNumber: doc['contactNumber'],
        templateReminderMsg: doc['templateReminderMsg'],
        templateFillInValues: doc['templateFillInValues'],
        reference: document.reference,
        notificationCount: doc['notificationCount']
        // TODO: Implement Family
        );
    client.service = Service.create(client);
    return client;
  }

  Map<String, Object> toDocument() {
    List<Map> _family = [];
    for (var fam in family) {
      _family.add({
        'firstName': fam.firstName,
        'lastName': fam.lastName,
        'relation': fam.relation
      });
    }
    List<Map> _dayPreferences = [];
    for (var day in dayPreferences) {
      _dayPreferences.add({
        'name': day.name,
        'favorableScale': day.favoribleScale.toString(),
      });
    }
    return {
      'adminUserId': adminUserId,
      'activeForCleaning': true,
      'firstName': firstName,
      'lastName': lastName,
      'streetAddress': streetAddress,
      'buildingNumber': buildingNumber,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'id': id,
      'userType': UserType.client.toString(),
      'paymentType': paymentType.toString(),
      'serviceTimePreference': serviceTimePreference.toString(),
      'serviceFrequency': serviceFrequency.toString(),
      'note': note ?? '',
      'keyRequired': keyRequired,
      'family': _family,
      'dayPreferences': _dayPreferences,
      'businessCode': '$businessCode',
      'lastCleaning':
          DateTime.parse(DateFormat('yyyyMMdd').format(DateTime.now())),
      'costPerCleaning': costPerCleaning,
      'contactNumber': formatPhoneNumber,
      'templateReminderMsg': templateReminderMsg ?? '',
      'templateFillInValues': templateFillInValues ?? [],
      'notificationCount': notificationCount,
    };
  }

  factory Client.familyFromDoc(Map<String, Object> fam) {
    return Client(
      firstName: fam['firstName'],
      lastName: fam['lastName'],
    );
  }
  factory Client.demo() {
    List<Day> _dayPreferenceList = [
      Day(name: 'Mon.'),
      Day(name: 'Tues.'),
      Day(name: 'Wed.'),
      Day(name: 'Thurs.'),
      Day(name: 'Fri.'),
      Day(name: 'Sat.'),
    ];
    return Client(
        adminUserId: 'adminUserId',
        streetAddress: 'street address',
        city: 'city ',
        state: 'state ',
        zipCode: 'zipCode ',
        contactNumber: '+19091234567',
        serviceFrequency: ServiceFrequency.biWeekly,
        serviceTimePreference: ServiceTimePreference.custom,
        firstName: 'Demo',
        lastName: 'Last',
        userType: UserType.client,
        dayPreferences: _dayPreferenceList,
        family: [],
        lastService: DateTime.parse(DateFormat('yyyyMMdd').format(
            DateTime.now().add(Duration(days: 3)).subtract(Duration(days: 7)))),
        templateFillInValues: [],
        templateReminderMsg: '',
        note: '',
        notificationCount: 0);
  }
  List<Client> familyFromDocument(List<Map<String, Object>> familyList) {
    return family = familyList.map((doc) => Client.familyFromDoc(doc)).toList();
  }
}

class DisplayDayPreferences extends StatelessWidget {
  final List<Day> dayPreferences;
  final bool withCard;
  final double sizeMultiplier;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry margin;

  DisplayDayPreferences(
      {@required this.dayPreferences,
      this.withCard = true,
      this.sizeMultiplier = 3.0,
      this.fontWeight,
      this.margin});
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return withCard
        ? Container(
            child: Card(
              elevation: 4,
              child: Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    for (var day in dayPreferences)
                      Container(
                          margin: margin,
                          child: Text(
                            day.name,
                            style: TextStyle(
                              fontWeight: fontWeight,
                              color: day.color,
                              fontSize: SizeConfig.safeBlockHorizontal *
                                  sizeMultiplier,
                            ),
                          ))
                  ],
                ),
              ),
            ),
          )
        : Container(
            margin: margin,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  for (var day in dayPreferences)
                    Container(
                        child: Text(
                      day.name,
                      style: TextStyle(
                        fontWeight: fontWeight,
                        color: day.color,
                        fontSize:
                            SizeConfig.safeBlockHorizontal * sizeMultiplier,
                      ),
                    ))
                ],
              ),
            ),
          );
  }
}
