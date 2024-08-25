import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trooptrak_final_application/core/theme/theme.dart';
import 'package:trooptrak_final_application/features/nominal_roll/domain/usecases/add_user_usecase.dart';
import 'features/nominal_roll/data/repositories/user_repository_impl.dart';
import 'features/nominal_roll/data/repositories/qr_scanner_repository_impl.dart';
import 'features/nominal_roll/domain/usecases/get_users_usecase.dart';
import 'features/nominal_roll/domain/usecases/update_user_attendance_usecase.dart';
import 'features/nominal_roll/domain/usecases/scan_qr_code_usecase.dart';
import 'features/nominal_roll/presentation/providers/user_provider.dart';
import 'features/nominal_roll/presentation/providers/qr_scanner_provider.dart';
import 'features/nominal_roll/presentation/pages/nominal_roll_screen.dart';
import 'features/nominal_roll/domain/usecases/get_user_by_id_usecase.dart';
import 'features/nominal_roll/domain/usecases/get_user_attendance_usecase.dart';
import 'features/nominal_roll/domain/usecases/get_user_statuses_usecase.dart';
import 'features/nominal_roll/presentation/providers/user_detail_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Provider.debugCheckInvalidValueType = null;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(450, 1000),
      child: MultiProvider(
        providers: [
          Provider<FirebaseFirestore>(
            create: (_) => FirebaseFirestore.instance,
          ),
          Provider<UserRepositoryImpl>(
            create: (context) =>
                UserRepositoryImpl(context.read<FirebaseFirestore>()),
          ),
          Provider<QRScannerRepositoryImpl>(
            create: (context) =>
                QRScannerRepositoryImpl(context.read<FirebaseFirestore>()),
          ),
          ProxyProvider<UserRepositoryImpl, GetUsersUseCase>(
            update: (_, repo, __) => GetUsersUseCase(repo),
          ),
          ProxyProvider<UserRepositoryImpl, UpdateUserAttendanceUseCase>(
            update: (_, repo, __) => UpdateUserAttendanceUseCase(repo),
          ),
          ProxyProvider<QRScannerRepositoryImpl, ScanQRCodeUseCase>(
            update: (_, repo, __) => ScanQRCodeUseCase(repo),
          ),
          ChangeNotifierProxyProvider2<GetUsersUseCase,
              UpdateUserAttendanceUseCase, UserProvider>(
            create: (context) => UserProvider(
              getUsersUseCase: context.read<GetUsersUseCase>(),
              updateUserAttendanceUseCase:
                  context.read<UpdateUserAttendanceUseCase>(),
            ),
            update: (_, getUsersUseCase, updateUserAttendanceUseCase, __) =>
                UserProvider(
              getUsersUseCase: getUsersUseCase,
              updateUserAttendanceUseCase: updateUserAttendanceUseCase,
            ),
          ),
          Provider<AddUserUseCase>(
            create: (context) =>
                AddUserUseCase(context.read<UserRepositoryImpl>()),
          ),
          ChangeNotifierProxyProvider3<ScanQRCodeUseCase, AddUserUseCase,
              UpdateUserAttendanceUseCase, QRScannerProvider>(
            create: (context) => QRScannerProvider(
              scanQRCodeUseCase: context.read<ScanQRCodeUseCase>(),
              addUserUseCase: context.read<AddUserUseCase>(),
            ),
            update: (_, scanQRCodeUseCase, addUserUseCase, __, previous) =>
                QRScannerProvider(
              scanQRCodeUseCase: scanQRCodeUseCase,
              addUserUseCase: addUserUseCase,
            ),
          ),
        ProxyProvider<UserRepositoryImpl, GetUserByIdUseCase>(
          update: (_, repo, __) => GetUserByIdUseCase(repo),
        ),
        ProxyProvider<UserRepositoryImpl, GetUserAttendanceUseCase>(
          update: (_, repo, __) => GetUserAttendanceUseCase(repo),
        ),
        ProxyProvider<UserRepositoryImpl, GetUserStatusesUseCase>(
          update: (_, repo, __) => GetUserStatusesUseCase(repo),
        ),
        ProxyProvider3<GetUserByIdUseCase, GetUserAttendanceUseCase, GetUserStatusesUseCase, UserDetailProvider>(
          update: (_, getUserByIdUseCase, getUserAttendanceUseCase, getUserStatusesUseCase, __) => UserDetailProvider(
            getUserByIdUseCase: getUserByIdUseCase,
            getUserAttendanceUseCase: getUserAttendanceUseCase,
            getUserStatusesUseCase: getUserStatusesUseCase,
          ),
        ),
      ],
     child: MaterialApp(
          title: 'User List App',
          theme: lightTheme,
          darkTheme: darkTheme,
          home: const NominalRollPage(),
        ),
    ),);
  }
}
