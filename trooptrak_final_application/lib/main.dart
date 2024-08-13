import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'sample_nr/data/repositories/user_repository_impl.dart';
import 'sample_nr/domain/usecases/get_users_usecase.dart';
import 'sample_nr/domain/usecases/update_user_attendance_usecase.dart';
import 'sample_nr/presentation/providers/user_provider.dart';
import 'sample_nr/presentation/pages/nominal_roll_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<UserRepositoryImpl>(
          create: (_) => UserRepositoryImpl(),
        ),
        ProxyProvider<UserRepositoryImpl, GetUsersUseCase>(
          update: (_, repo, __) => GetUsersUseCase(repo),
        ),
        ProxyProvider<UserRepositoryImpl, UpdateUserAttendanceUseCase>(
          update: (_, repo, __) => UpdateUserAttendanceUseCase(repo),
        ),
        ChangeNotifierProxyProvider2<GetUsersUseCase, UpdateUserAttendanceUseCase, UserProvider>(
          create: (context) => UserProvider(
            getUsersUseCase: context.read<GetUsersUseCase>(),
            updateUserAttendanceUseCase: context.read<UpdateUserAttendanceUseCase>(),
          ),
          update: (_, getUsersUseCase, updateUserAttendanceUseCase, __) => UserProvider(
            getUsersUseCase: getUsersUseCase,
            updateUserAttendanceUseCase: updateUserAttendanceUseCase,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'User List App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const NominalRollPage(),
      ),
    );
  }
}