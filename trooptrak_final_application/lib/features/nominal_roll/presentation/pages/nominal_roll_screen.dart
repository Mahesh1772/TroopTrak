import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/user.dart';
import '../providers/user_provider.dart';
import '../widgets/user_tile.dart';
import 'qr_scanner_page.dart';

class NominalRollPage extends StatefulWidget {
  const NominalRollPage({super.key});

  @override
  State<NominalRollPage> createState() => _NominalRollPageState();
}

class _NominalRollPageState extends State<NominalRollPage> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 72, 30, 229),
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
        child: const Icon(
          Icons.add,
          color: Colors.white,
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
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 26.sp,
                      ),
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
          SizedBox(
            height: 20.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0.w),
            child: Text(
              'Our Family of Soldiers:',
              style: Theme.of(context).textTheme.displayMedium,
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
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
                focusColor: Colors.white,
                prefixIcon: const Icon(
                  Icons.search_sharp,
                  color: Colors.white,
                ),
                prefixIconColor: Colors.white,
                fillColor: const Color.fromARGB(255, 72, 30, 229),
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide.none),
              ),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<User>>(
              stream: context.read<UserProvider>().users,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
