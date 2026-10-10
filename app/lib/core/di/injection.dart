import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/attendance/data/datasources/attendance_remote_data_source.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/domain/usecases/attendance_usecases.dart';
import '../../features/attendance/domain/usecases/watch_soldiers_in_camp.dart';
import '../../features/auth/data/datasources/firebase_auth_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/domain/usecases/complete_soldier_profile.dart';
import '../../features/auth/domain/usecases/delete_commander_account.dart';
import '../../features/auth/domain/usecases/register_commander.dart';
import '../../features/auth/domain/usecases/soldier_entry.dart';
import '../../features/auth/domain/usecases/update_soldier_profile.dart';
import '../../features/conducts/data/datasources/conduct_remote_data_source.dart';
import '../../features/conducts/data/repositories/conduct_repository_impl.dart';
import '../../features/conducts/domain/repositories/conduct_repository.dart';
import '../../features/conducts/domain/usecases/build_conduct_roster.dart';
import '../../features/conducts/domain/usecases/conduct_usecases.dart';
import '../../features/conducts/domain/usecases/watch_conduct_breakdown.dart';
import '../../features/dashboard/domain/usecases/watch_calendar_events.dart';
import '../../features/dashboard/domain/usecases/watch_strength_summary.dart';
import '../../features/enlistment/data/datasources/men_remote_data_source.dart';
import '../../features/enlistment/data/repositories/men_repository_impl.dart';
import '../../features/enlistment/domain/repositories/men_repository.dart';
import '../../features/enlistment/domain/usecases/men_usecases.dart';
import '../../features/guard_duty/data/datasources/duty_remote_data_source.dart';
import '../../features/guard_duty/data/repositories/duty_repository_impl.dart';
import '../../features/guard_duty/domain/repositories/duty_repository.dart';
import '../../features/guard_duty/domain/usecases/duty_usecases.dart';
import '../../features/onboarding/data/repositories/role_repository_impl.dart';
import '../../features/onboarding/domain/usecases/role_usecases.dart';
import '../../features/soldiers/data/datasources/soldier_remote_data_source.dart';
import '../../features/soldiers/data/repositories/soldier_repository_impl.dart';
import '../../features/soldiers/domain/repositories/soldier_repository.dart';
import '../../features/soldiers/domain/usecases/soldier_usecases.dart';
import '../../features/statuses/data/datasources/status_remote_data_source.dart';
import '../../features/statuses/data/repositories/status_repository_impl.dart';
import '../../features/statuses/domain/repositories/status_repository.dart';
import '../../features/statuses/domain/usecases/status_usecases.dart';
import '../services/clock.dart';
import '../services/id_generator.dart';
import '../services/preferences_service.dart';
import '../services/tick_source.dart';
import '../theme/theme_manager.dart';
import 'calendar_event_adapter.dart';

/// Composition root. Firebase instances are resolved lazily, on first use.
class AppDependencies {
  AppDependencies({
    required this.preferences,
    this.clock = const SystemClock(),
    this.ticks = const PeriodicTickSource(),
    this.ids = const UuidGenerator(),
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore,
        _auth = auth;

  final PreferencesService preferences;
  final Clock clock;
  final TickSource ticks;
  final IdGenerator ids;
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  static Future<AppDependencies> create() async =>
      AppDependencies(preferences: await PreferencesService.create());

  late final FirebaseFirestore firestore =
      _firestore ?? FirebaseFirestore.instance;
  late final FirebaseAuth auth = _auth ?? FirebaseAuth.instance;

  late final SoldierRepository soldiers =
      SoldierRepositoryImpl(SoldierRemoteDataSource(firestore));
  late final AuthRepository authRepository =
      AuthRepositoryImpl(FirebaseAuthDataSource(auth), preferences);
  late final MenRepository men =
      MenRepositoryImpl(MenRemoteDataSource(firestore));
  late final StatusRepository statuses =
      StatusRepositoryImpl(StatusRemoteDataSource(firestore));
  late final AttendanceRepository attendance =
      AttendanceRepositoryImpl(AttendanceRemoteDataSource(firestore));
  late final ConductRepository conducts =
      ConductRepositoryImpl(ConductRemoteDataSource(firestore));
  late final DutyRepository duties =
      DutyRepositoryImpl(DutyRemoteDataSource(firestore));

  List<SingleChildWidget> get providers {
    final roles = RoleRepositoryImpl(preferences);
    return [
      Provider<Clock>.value(value: clock),
      Provider<TickSource>.value(value: ticks),
      Provider<PreferencesService>.value(value: preferences),
      ChangeNotifierProvider<ThemeManager>(create: (_) => ThemeManager()),
      Provider(create: (_) => GetRole(roles)),
      Provider(create: (_) => SetRole(roles)),
      ..._soldierProviders(),
      ..._statusProviders(),
      ..._attendanceProviders(),
      ..._conductProviders(),
      ..._dutyProviders(),
      Provider(
        create: (_) =>
            WatchCalendarEvents(CalendarEventAdapter(conducts, duties)),
      ),
      ..._authProviders(),
    ];
  }

  List<SingleChildWidget> _dutyProviders() => [
        Provider(create: (_) => WatchDuties(duties)),
        Provider(create: (_) => AddDuty(duties)),
        Provider(create: (_) => UpdateDuty(duties)),
        Provider(create: (_) => DeleteDuty(duties)),
        Provider(create: (_) => GetDutyRoster(soldiers, statuses, clock)),
      ];

  List<SingleChildWidget> _conductProviders() => [
        Provider(create: (_) => WatchConductsOnDay(conducts)),
        Provider(create: (_) => AddConduct(conducts)),
        Provider(create: (_) => UpdateConduct(conducts)),
        Provider(create: (_) => DeleteConduct(conducts)),
        Provider(create: (_) => BuildConductRoster(soldiers, statuses, clock)),
        Provider(create: (_) => WatchConductBreakdown(conducts, soldiers)),
      ];

  List<SingleChildWidget> _attendanceProviders() => [
        Provider(create: (_) => WatchAttendance(attendance, clock)),
        Provider(create: (_) => UpdateAttendance(attendance)),
        Provider(create: (_) => DeleteAttendance(attendance)),
        Provider(create: (_) => BookInOut(attendance, clock)),
        Provider(
            create: (_) => WatchSoldiersInCamp(soldiers, attendance, clock)),
        Provider(
          create: (_) => WatchStrengthSummary(
              WatchSoldiersInCamp(soldiers, attendance, clock),
              statuses,
              clock),
        ),
      ];

  List<SingleChildWidget> _statusProviders() => [
        Provider(create: (_) => WatchSoldierStatuses(statuses)),
        Provider(create: (_) => AddStatus(statuses)),
        Provider(create: (_) => UpdateStatus(statuses)),
        Provider(create: (_) => DeleteStatus(statuses)),
      ];

  List<SingleChildWidget> _soldierProviders() => [
        Provider(create: (_) => WatchSoldiers(soldiers)),
        Provider(create: (_) => WatchSoldier(soldiers)),
        Provider(create: (_) => AddSoldier(soldiers, clock)),
        Provider(create: (_) => UpdateSoldier(soldiers)),
        Provider(create: (_) => DeleteSoldier(soldiers)),
      ];

  List<SingleChildWidget> _authProviders() => [
        Provider(create: (_) => WatchAuthState(authRepository)),
        Provider(create: (_) => SignInWithEmail(authRepository)),
        Provider(create: (_) => SendPasswordReset(authRepository)),
        Provider(create: (_) => VerifyPhone(authRepository)),
        Provider(create: (_) => VerifyOtp(authRepository)),
        Provider(create: (_) => SignOut(authRepository)),
        Provider(
            create: (_) => RegisterCommander(authRepository, soldiers, clock)),
        Provider(create: (_) => SoldierProfileExists(men)),
        Provider(create: (_) => FindRegistrationByQr(men)),
        Provider(create: (_) => WatchOwnRegistration(men)),
        Provider(create: (_) => PublishEnlistmentQr(men, ids)),
        Provider(create: (_) => ClearEnlistmentQr(men)),
        Provider(
            create: (_) => UpdateSoldierProfile(authRepository, men, soldiers)),
        Provider(create: (_) => ResolveSoldierEntry(authRepository, men)),
        Provider(create: (_) => CompleteSoldierSignIn(authRepository, men)),
        Provider(create: (_) => CompleteSoldierProfile(authRepository, men)),
        Provider(
            create: (_) =>
                DeleteCommanderAccount(authRepository, soldiers, clock)),
      ];
}
