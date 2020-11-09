import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:the_cleaning_ladies/src/Admin/EasyDB/EasyDb.dart';
import 'package:the_cleaning_ladies/src/Models/User/user.dart';
import 'package:the_cleaning_ladies/src/Models/historyEvent.dart';

enum CleaningTimePreference { earlyMornings, lateMornings, afternoons, custom }
enum PaymentType { cash, check, quickPay }
enum CleaningFrequency { weekly, biWeekly, monthly, custom }
enum FavoribleScale { notOkay, isOkay, isPrefered }
enum CleaningDifficulty { easy, medium, hard }

class Day {
  String name;
  FavoribleScale favoribleScale = FavoribleScale.notOkay;
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
  String businessCode;
  String streetAddress;
  String note;
  bool keyRequired = false;
  bool active = true;
  int costPerCleaning;
  String contactNumber;
  String buildingNumber;
  String city;
  String state;
  String zipCode;
  String templateReminderMsg;
  DocumentReference reference;
  FirebaseFirestore _db = FirebaseFirestore.instance;

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

  Stream<List<HistoryEvent>> get cleaningHistory {
    return _db
        .collection('Users/$id/Cleaning History')
        .orderBy('from', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => HistoryEvent.fromDocument(doc))
            .toList());
  }

  Stream<List<HistoryEvent>> get totalEarnedFromCustomer {
    return _db
        .collection('Users/$id/Cleaning History')
        .orderBy('from', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => HistoryEvent.fromDocument(doc))
            .toList());
  }

  DateTime get lastCleaningDateOnly =>
      DateTime(lastCleaning.year, lastCleaning.month, lastCleaning.day);

  String get formattedLastCleaning =>
      DateFormat('MM/dd/yy').format(lastCleaning);
  CleaningFrequency cleaningFrequencyFromDoc(DocumentSnapshot document) {
    Map<String, dynamic> doc = document.data();

    return CleaningFrequency.values.firstWhere((freq) =>
        (freq.toString() == doc['cleaningFrequency']) ??
        CleaningFrequency.weekly);
  }

  CleaningFrequency cleaningFrequency = CleaningFrequency.weekly;
  CleaningTimePreference cleaningTimePreference =
      CleaningTimePreference.earlyMornings;
  // TODO: Implement Cleaning Difficulty
  CleaningDifficulty cleaningDifficulty;
  PaymentType paymentType = PaymentType.cash;
  DateTime lastCleaning;
  Map<String, DateTime> calculateNextCleaning() {
    switch (cleaningFrequency) {
      case CleaningFrequency.weekly:
        return {
          'from': lastCleaning.add(Duration(days: 7)),
          'to': lastCleaning.add(Duration(days: 7))
        };
        break;
      case CleaningFrequency.biWeekly:
        return {
          'from': lastCleaning.add(Duration(days: 14)),
          'to': lastCleaning.add(Duration(days: 14))
        };
        break;
      case CleaningFrequency.monthly:
        return {
          'from': lastCleaning.add(Duration(days: 31)),
          'to': lastCleaning.add(Duration(days: 31))
        };
        break;
      case CleaningFrequency.custom:
        return {
          'from': lastCleaning.add(Duration(days: 60)),
          'to': lastCleaning.add(Duration(days: 60))
        };
        break;
      default:
        return {};
    }
  }

  EasyDB _easyDB = DataBaseRepo();
  void setLastCleaning(DateTime time, Function() onCompletion) => _easyDB
      .editDocumentData('Users/$id', {'lastCleaning': time}).whenComplete(
          () => onCompletion());
  String get nextCleaning {
    Map<String, DateTime> nextCleaning = calculateNextCleaning();
    return DateFormat('MM/dd/yy').format(nextCleaning['from']);
  }

  String get formatPhoneNumber {
    String removeParathesis = contactNumber.replaceAll(RegExp(r'(\(|\))'), '');
    return removeParathesis.trim().replaceAll(RegExp(r'(\s)'), '');
  }

  Map weekDays = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };
  String get nextCleaningWeekDay {
    Map<String, DateTime> nextCleaning = calculateNextCleaning();
    return weekDays[nextCleaning['from'].weekday];
  }

  String get formattedAddress {
    return "$streetAddress $buildingNumber \n$city $state $zipCode";
  }

  List<Day> dayPreferences = [
    // Day(name: 'Mon.',favoribleScale: FavoribleScale.isOkay),
    // Day(name: 'Tues.',favoribleScale: FavoribleScale.isOkay),
    // Day(name: 'Wed.',favoribleScale: FavoribleScale.isOkay),
    // Day(name: 'Thurs.',favoribleScale: FavoribleScale.isOkay),
    // Day(name: 'Fri.',favoribleScale: FavoribleScale.isOkay),
    // Day(name: 'Sat.',favoribleScale: FavoribleScale.isOkay),
  ];

  List<User> family = <User>[];
  List<dynamic> templateFillInValues = [];
  Client(
      {String firstName,
      String lastName,
      String id,
      UserType userType,
      this.note,
      this.keyRequired,
      this.businessCode,
      this.active,
      this.dayPreferences,
      this.cleaningFrequency = CleaningFrequency.weekly,
      this.cleaningTimePreference = CleaningTimePreference.earlyMornings,
      this.streetAddress,
      this.buildingNumber,
      this.city,
      this.state,
      this.zipCode,
      this.paymentType,
      this.lastCleaning,
      this.family,
      this.customTimePreference,
      this.costPerCleaning,
      this.contactNumber,
      this.templateReminderMsg,
      this.templateFillInValues,
      this.reference})
      : super(
            firstName: firstName,
            lastName: lastName,
            id: id,
            userType: userType);
  factory Client.fromQueryDocSnapDocument(QueryDocumentSnapshot document) {
    Map<String, dynamic> doc = document.data();
    Day day = Day();
    List familyFromDoc = doc['family'];
    List<User> family = [];
    for (var fam in familyFromDoc) {
      family
          .add(Client(firstName: fam['firstName'], lastName: doc['lastName']));
    }
    List<Day> dayPreferenceList =
        (day.fromDocumentFavorableScale(doc['dayPreferences']));
    CleaningFrequency cleaningFrequency = CleaningFrequency.values.firstWhere(
        (freq) =>
            (freq.toString() == doc['cleaningFrequency']) ??
            CleaningFrequency.weekly);
    CleaningTimePreference cleaningTimePreference = CleaningTimePreference
        .values
        .firstWhere((pref) => pref.toString() == doc['cleaningTimePreference']);
    return Client(
        firstName: doc['firstName'].toString(),
        lastName: doc['lastName'].toString(),
        streetAddress: doc['streetAddress'].toString(),
        buildingNumber: doc['buildingNumber'].toString(),
        city: doc['city'].toString(),
        state: doc['state'].toString(),
        zipCode: doc['zipCode'].toString(),
        active: doc['activeForCleaning'],
        lastCleaning: (doc['lastCleaning'] as Timestamp).toDate(),
        userType: UserType.client,
        cleaningFrequency: cleaningFrequency,
        cleaningTimePreference: cleaningTimePreference,
        dayPreferences: dayPreferenceList,
        businessCode: doc['businessCode'],
        keyRequired: doc['keyRequired'],
        note: doc['note'] ?? '',
        paymentType: doc['paymentType'],
        id: doc['id'],
        family: family,
        costPerCleaning: doc['costPerCleaning'] ?? 0,
        contactNumber: doc['contactNumber'],
        templateReminderMsg: doc['templateReminderMsg'],
        templateFillInValues: doc['templateFillInValues'],
        reference: document.reference
        // TODO: Implement Family
        );
  }
  factory Client.fromDocSnapDocument(DocumentSnapshot document) {
    Map<String, dynamic> doc = document.data();
    Day day = Day();
    List familyFromDoc = doc['family'];
    List<User> family = [];
    for (var fam in familyFromDoc) {
      family
          .add(Client(firstName: fam['firstName'], lastName: doc['lastName']));
    }
    List<Day> dayPreferenceList =
        (day.fromDocumentFavorableScale(doc['dayPreferences']));
    CleaningFrequency cleaningFrequency = CleaningFrequency.values.firstWhere(
        (freq) =>
            (freq.toString() == doc['cleaningFrequency']) ??
            CleaningFrequency.weekly);
    CleaningTimePreference cleaningTimePreference = CleaningTimePreference
        .values
        .firstWhere((pref) => pref.toString() == doc['cleaningTimePreference']);
    return Client(
        firstName: doc['firstName'].toString(),
        lastName: doc['lastName'].toString(),
        streetAddress: doc['streetAddress'].toString(),
        buildingNumber: doc['buildingNumber'].toString(),
        city: doc['city'].toString(),
        state: doc['state'].toString(),
        zipCode: doc['zipCode'].toString(),
        active: doc['activeForCleaning'],
        lastCleaning: (doc['lastCleaning'] as Timestamp).toDate(),
        userType: UserType.client,
        cleaningFrequency: cleaningFrequency,
        cleaningTimePreference: cleaningTimePreference,
        dayPreferences: dayPreferenceList,
        businessCode: doc['businessCode'],
        keyRequired: doc['keyRequired'],
        note: doc['note'] ?? '',
        paymentType: doc['paymentType'],
        id: doc['id'],
        family: family,
        costPerCleaning: doc['costPerCleaning'] ?? 0,
        contactNumber: doc['contactNumber'],
        templateReminderMsg: doc['templateReminderMsg'],
        templateFillInValues: doc['templateFillInValues'],
        reference: document.reference
        // TODO: Implement Family
        );
  }
  factory Client.fromMap(Map<String, Object> map) {
    Day day = Day();
    List familyFromDoc = map['family'];
    List<User> family = [];
    for (var fam in familyFromDoc) {
      family
          .add(Client(firstName: fam['firstName'], lastName: map['lastName']));
    }
    List<Day> dayPreferenceList =
        (day.fromDocumentFavorableScale(map['dayPreferences']));
    CleaningFrequency cleaningFrequency = CleaningFrequency.values.firstWhere(
        (freq) =>
            (freq.toString() == map['cleaningFrequency']) ??
            CleaningFrequency.weekly);
    CleaningTimePreference cleaningTimePreference = CleaningTimePreference
        .values
        .firstWhere((pref) => pref.toString() == map['cleaningTimePreference']);
    return Client(
        firstName: map['firstName'].toString(),
        lastName: map['lastName'].toString(),
        streetAddress: map['streetAddress'].toString(),
        city: map['city'].toString(),
        buildingNumber: map['buildingNumber'].toString(),
        state: map['state'].toString(),
        zipCode: map['zipCode'].toString(),
        active: map['activeForCleaning'],
        lastCleaning: (map['lastCleaning'] as Timestamp).toDate(),
        userType: UserType.client,
        cleaningFrequency: cleaningFrequency,
        cleaningTimePreference: cleaningTimePreference,
        dayPreferences: dayPreferenceList,
        businessCode: map['businessCode'],
        keyRequired: map['keyRequired'],
        note: map['note'],
        paymentType: map['paymentType'],
        id: map['id'],
        family: family,
        costPerCleaning: map['costPerCleaning'],
        contactNumber: map['contactNumber'],
        templateReminderMsg: map['templateReminderMsg'],
        templateFillInValues: map['templateFillInValues']

        // TODO: Implement Family
        );
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
      'paymentType': paymentType,
      'cleaningTimePreference': cleaningTimePreference.toString(),
      'cleaningFrequency': cleaningFrequency.toString(),
      'note': note,
      'keyRequired': keyRequired,
      'family': _family,
      'dayPreferences': _dayPreferences,
      // TODO: Make businessCode dynamic
      'businessCode': 'TCL',
      'lastCleaning':
          DateTime.parse(DateFormat('yyyyMMdd').format(DateTime.now())),
      'costPerCleaning': costPerCleaning,
      'contactNumber': contactNumber,
      'templateReminderMsg': templateReminderMsg,
      'templateFillInValues': templateFillInValues
    };
  }

  Map<String, Object> toDocumentDemos() {
    List<Map> _family = [];
    if (family != null) {
      for (var fam in family) {
        _family.add({
          'firstName': fam.firstName,
          'lastName': fam.lastName,
          'relation': fam.relation
        });
      }
    }

    List<Map> _dayPreferences = [];
    for (var day in dayPreferences) {
      int randInt3forFavScale = Random().nextInt(3);

      day.favoribleScale = FavoribleScale.values.elementAt(randInt3forFavScale);
      _dayPreferences.add({
        'name': day.name,
        'favorableScale': day.favoribleScale.toString(),
      });
    }
    costPerCleaning = Random().nextInt(160);
    return {
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
      'paymentType': paymentType,
      'cleaningTimePreference': cleaningTimePreference.toString(),
      'cleaningFrequency': cleaningFrequency.toString(),
      'note': note,
      'keyRequired': keyRequired,
      'family': _family,
      'dayPreferences': _dayPreferences,
      // TODO: Make businessCode dynamic
      'businessCode': 'TCL',
      'lastCleaning': lastCleaning,
      'costPerCleaning': costPerCleaning,
      'contactNumber': contactNumber,
      'templateReminderMsg': templateReminderMsg,
      'templateFillInValues': templateFillInValues
    };
  }
  // Map doc = {'firstName': client.firstName};
  // return doc;

  void get handleIsActive {
    EasyDB _db = DataBaseRepo();

    _db.editDocumentData('Users/$id', {'activeForCleaning': !active});
    active = !active;
  }

  String get showCleaningFrequencyText {
    switch (cleaningFrequency) {
      case CleaningFrequency.weekly:
        return 'Weekly';
        break;
      case CleaningFrequency.biWeekly:
        return 'Bi-Weekly';
        break;
      case CleaningFrequency.monthly:
        return 'Monthly';
        break;
      case CleaningFrequency.custom:
        //TODO: Functionality for Custom Cleaning Frequency
        return 'Custom';
        break;
      default:
        return 'Not Available';
    }
  }

  String get showCleaningTimePreferenceText {
    switch (cleaningTimePreference) {
      case CleaningTimePreference.earlyMornings:
        return 'Early Mornings';
        break;
      case CleaningTimePreference.lateMornings:
        return 'Late Mornings';
        break;
      case CleaningTimePreference.afternoons:
        return 'Afternoons';
        break;
      default:
        return 'Not Available';
    }
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
        streetAddress: 'street address',
        city: 'city ',
        state: 'state ',
        zipCode: 'zipCode ',
        contactNumber: '+19091234567',
        cleaningFrequency: CleaningFrequency.biWeekly,
        cleaningTimePreference: CleaningTimePreference.custom,
        firstName: 'Demo',
        lastName: 'Last',
        userType: UserType.client,
        dayPreferences: _dayPreferenceList,
        family: [],
        lastCleaning: DateTime.parse(DateFormat('yyyyMMdd').format(
            DateTime.now().add(Duration(days: 3)).subtract(Duration(days: 7)))),
        templateFillInValues: [],
        templateReminderMsg: '');
  }
  List<Client> familyFromDocument(List<Map<String, Object>> familyList) {
    return family = familyList.map((doc) => Client.familyFromDoc(doc)).toList();
  }
}
