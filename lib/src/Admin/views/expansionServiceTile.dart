import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/service/service.dart';
import 'package:the_cleaning_ladies/models/time_tile/time_title.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/src/admin/views/Settings/my_services/my_services.dart';

class ExpansionServiceTile extends StatefulWidget {
  final Admin admin;
  final TimeTile time;
  final List<TimeTile> availableTimes;
  final Function(int, bool) recalculateNextAppointment;
  final Function() resetTimeToOriginal;
  ExpansionServiceTile({
    @required this.admin,
    @required this.time,
    @required this.availableTimes,
    @required this.recalculateNextAppointment,
    @required this.resetTimeToOriginal,
  });
  @override
  _ExpansionServiceTileState createState() => _ExpansionServiceTileState();
}

class _ExpansionServiceTileState extends State<ExpansionServiceTile> {
  bool withTravelTime = true;
  @override
  Widget build(BuildContext context) {
    TimeTile time = widget.time;
    Appointment appointment = time.appointment;
    List<Service> services = List<Service>.of(appointment.services);
    return Container(
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          bool isExpanded = appointment.isExpanded;
          setState(() {
            appointment.isExpanded = !isExpanded;
          });
        },
        children: [
          ExpansionPanel(
              headerBuilder: (context, isExpanded) {
                return ListTile(
                    title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        child: Text('${appointment?.eventName ?? ''}'),
                      ),
                    ),
                    Flexible(
                      // flex: 0,
                      child: Container(
                        child: Text(
                            '${time.fromTimeFormatted} - ${time.toTimeFormatted}'),
                      ),
                    ),
                  ],
                ));
              },
              body: Column(
                children: [
                  time.appointment.appointmentId != null
                      ? Container()
                      : CheckboxListTile(
                          value: withTravelTime,
                          onChanged: time.appointment.appointmentId != null
                              ? null
                              : (val) {
                                  setState(() {
                                    withTravelTime = val;
                                    services.forEach((service) {
                                      service.selected = false;
                                    });
                                    widget.resetTimeToOriginal();
                                  });
                                },
                          title: Text('Calculate with Travel Time?'),
                        ),
                  Container(
                      height: 200,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          Service service = services[index];
                          return InkWell(
                            onTap: time.appointment.appointmentId != null
                                ? null
                                : () {
                                    bool selected = service.selected;

                                    setState(() {
                                      service.selected = !selected;
                                      calculateNextTimeSlot(service, services);
                                    });
                                  },
                            child: ServiceTile(
                              service: service,
                              onlyShowing: false,
                            ),
                          );
                        },
                        itemCount: services.length,
                      )),
                ],
              ),
              isExpanded: appointment.isExpanded)
        ],
      ),
    );
  }

  void calculateNextTimeSlot(Service service, List<Service> services) {
    Admin admin = widget.admin;
    ScheduleSettings ss = admin.scheduleSettings;
    ElapsedTime timeBetweenService = ss.timeBetweenService;
    int addedMinutes = 0;
    if (service.selected) {
      services.forEach((service) {
        if (service.selected) {
          addedMinutes += service.duration.inMinutes;
        }
      });
      widget.recalculateNextAppointment(
          withTravelTime
              ? addedMinutes +
                  timeBetweenService.min +
                  (timeBetweenService.hour * 60)
              : addedMinutes,
          true);
    } else {
      addedMinutes += service.duration.inMinutes;

      widget.recalculateNextAppointment(
          withTravelTime ? addedMinutes : addedMinutes, false);
      if (noServicesSelected(services)) {
        widget.resetTimeToOriginal();
      }
    }
  }

  bool noServicesSelected(List<Service> services) {
    int selectedServices = 0;
    services.forEach((service) {
      if (service.selected) {
        selectedServices++;
      }
    });

    return selectedServices > 0 ? false : true;
  }
}
