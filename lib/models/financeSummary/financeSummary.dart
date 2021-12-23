import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';

class FinanceSummary {
  Admin admin;

  FinanceSummary.init({@required this.admin});

  Future<double> getDayTotal(int day, DateTime start) async {
    List<Appointment> _appointments = await admin.getAppointments();
    _appointments.removeWhere((appointment) => !appointment.fromDateOnly
        .isAtSameMomentAs(start.add(Duration(days: day))));
    // print(_appointments.length);
    double total = 0;
    _appointments.forEach((appointment) {
      if (appointment.services.isNotEmpty) {
        appointment.services.forEach((service) {
          if (service.selected) {
            total += service.cost;
          }
        });
      }
      total += appointment.serviceCost;
    });
    // print(total);
    return total;
  }

  Future<double> getWeekTotal(DateTime start) async {
    List<Appointment> _appointments = await admin.getAppointments();
    _appointments.removeWhere((appointment) =>
        appointment.checkInTheWeek(start, start.add(Duration(days: 6))));
    double total = 0;
    _appointments.forEach((appointment) {
      if (appointment.services.isNotEmpty) {
        appointment.services.forEach((service) {
          if (service.selected) {
            total += service.cost;
          }
        });
      }
      total += appointment.serviceCost;
    });
    return total;
  }

  Future<int> get getTotalClients async {
    List<Client> _customers = await admin.getAllClients();
    return _customers.length;
  }

  Future<double> getTotalMonthlyProfit(int month) async {
    double total = 0;
    List<Appointment> _appointments =
        await admin.getAppointments(confirmedOnly: true);
    _appointments.forEach((appointment) {
      if (appointment.from.month == month) {
        if (appointment.services.isNotEmpty) {
          appointment.services.forEach((service) {
            if (service.selected) {
              total += service.cost;
            }
          });
        }
        total += appointment.serviceCost;
      }
    });
    return total;
  }

  Future<double> get getTotalClientsMonthlyPay async {
    double total = 0;
    List<Client> _customers = await admin.getAllClients(activeOnly: true);
    _customers.forEach((client) {
      switch (client.serviceFrequency) {
        case ServiceFrequency.weekly:
          total += client.costPerCleaning * 4;

          break;
        case ServiceFrequency.biWeekly:
          total += client.costPerCleaning * 2;

          break;
        default:
          total += client.costPerCleaning;
      }
    });
    return total;
  }

  Future<double> getWeekTotalMinusWorkerFees() async {
    List<Appointment> _appointments = await admin.getAppointments();

    _appointments.removeWhere((appointment) => appointment.checkInTheWeek(
        DateTime(2020, 10, 5), DateTime(2020, 10, 11)));
    double total = 0;
    print(_appointments.length);
    _appointments.forEach((appointment) => total += appointment.serviceCost);
    return total;
  }
}
