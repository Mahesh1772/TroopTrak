import '../../../../core/utils/date_formats.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../entities/status.dart';

/// R21 told to the commander before saving: Leave and Medical Appointment book
/// the soldier out and back in. Null for an Excuse.
String? bookOutNote(Status draft, Soldier soldier) {
  if (!draft.booksOut) return null;
  return '${draft.type} books ${_firstName(soldier.name)} out at '
      '${formatClock(draft.bookOutAt)} on the start day and back in at '
      '${formatClock(draft.bookInAt)} on the end day.';
}

String _firstName(String name) => name.trim().split(RegExp(r'\s+')).first;
