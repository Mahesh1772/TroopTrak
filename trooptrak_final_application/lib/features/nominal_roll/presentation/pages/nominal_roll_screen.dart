import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/user.dart';
import '../providers/user_provider.dart';
import '../widgets/user_tile.dart';
import 'qr_scanner_page.dart';
import '../../../../core/theme/theme_manager.dart';

class NominalRollPage extends StatefulWidget {
  const NominalRollPage({super.key});

  @override
  State<NominalRollPage> createState() => _NominalRollPageState();
}

class _NominalRollPageState extends State<NominalRollPage> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeManager = Provider.of<ThemeManager>(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.secondary,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return const QRScannerPage();
            },
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
          );
        },
        child: Icon(
          Icons.add,
          color: theme.colorScheme.tertiary,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                child: Text(
                  'Nominal Roll',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 26.sp,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      themeManager.toggleTheme(themeManager.themeMode == ThemeMode.light);
                    },
                    icon: Icon(
                      themeManager.themeMode == ThemeMode.dark 
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: theme.colorScheme.tertiary,
                      size: 24.sp,
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.all(12.0.sp),
                      child: Image.asset(
                        'lib/assets/user.png',
                        width: 50.w,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 20.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0.w),
            child: Text(
              'Our Family of Soldiers:',
              style: theme.textTheme.displayMedium,
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Padding(
            padding: EdgeInsets.all(20.0.sp),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search Name',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.tertiary,
                ),
                focusColor: theme.colorScheme.tertiary,
                prefixIcon: Icon(
                  Icons.search_sharp,
                  color: theme.colorScheme.tertiary,
                ),
                prefixIconColor: theme.colorScheme.tertiary,
                fillColor: theme.colorScheme.secondary,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none,
                ),
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.tertiary,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<User>>(
              stream: context.read<UserProvider>().users,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.secondary,
                    ),
                  );
                }
                final users = snapshot.data ?? [];
                final filteredUsers = users
                    .where((user) => user.name
                        .toLowerCase()
                        .contains(searchText.toLowerCase()))
                    .toList();
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 10.0,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    return UserTile(user: filteredUsers[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
