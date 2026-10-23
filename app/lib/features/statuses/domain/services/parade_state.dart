import '../../../soldiers/domain/entities/soldier.dart';
import '../entities/status.dart';

/// Declared in tick-strip order, so `index` is the sort order.
enum ParadeState {
  inCamp,
  excuse,
  medical,
  leave,
  out;

  /// D9: the "in camp" figure counts an excuse too.
  bool get isInCamp => this == inCamp || this == excuse;

  String get label => switch (this) {
        inCamp => 'In camp',
        excuse => 'Excuse · in camp',
        medical => 'Medical Appointment',
        leave => 'Leave',
        out => 'Booked out',
      };
}

/// D9: Leave and Medical Appointment override the booked-in flag; an Excuse
/// only shows while in camp. The caller picks [activeStatus], `null` for none.
ParadeState paradeStateOf(Soldier soldier, Status? activeStatus) =>
    switch (activeStatus) {
      Status(isLeave: true) => ParadeState.leave,
      Status(isMedicalAppointment: true) => ParadeState.medical,
      _ when !soldier.isInCamp => ParadeState.out,
      Status(isExcuse: true) => ParadeState.excuse,
      _ => ParadeState.inCamp,
    };
