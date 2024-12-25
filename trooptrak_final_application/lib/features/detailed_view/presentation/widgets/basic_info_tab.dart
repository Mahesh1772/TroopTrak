import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../features/nominal_roll/domain/entities/user.dart';
import '../../../../features/nominal_roll/presentation/providers/user_detail_provider.dart';
import '../../../../features/nominal_roll/presentation/pages/edit_soldier_screen.dart';

class BasicInfoTab extends StatefulWidget {
  final String userId;

  const BasicInfoTab({super.key, required this.userId});

  @override
  State<BasicInfoTab> createState() => _BasicInfoTabState();
}

class _BasicInfoTabState extends State<BasicInfoTab> {
  @override
  void initState() {
    super.initState();
    // Load user data once when the widget is initialized
    Future.microtask(() =>
        Provider.of<UserDetailProvider>(context, listen: false)
            .loadUser(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Consumer<UserDetailProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<User?>(
          stream: provider.userStream,
          initialData: provider.user,
          builder: (context, snapshot) {
            if (provider.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                  strokeWidth: 2.w,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                    letterSpacing: 1.2,
                    fontSize: 14.sp,
                  ),
                ),
              );
            }

            final user = snapshot.data;
            if (user == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 32.sp,
                      color: theme.colorScheme.error,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'User not found',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.tertiary,
                        letterSpacing: 1.2,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: isDarkMode 
                              ? Color.fromARGB(255, 45, 50, 65)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode 
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: 4.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 20.sp,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Personal Information",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.tertiary,
                          letterSpacing: 1.2,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.only(left: 12.w),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          Icons.cake_rounded,
                          'Date of Birth',
                          user.dob,
                        ),
                        SizedBox(height: 24.h),
                        _buildInfoRow(
                          context,
                          Icons.food_bank_rounded,
                          'Ration Type',
                          user.rationType,
                        ),
                        SizedBox(height: 24.h),
                        _buildInfoRow(
                          context,
                          Icons.bloodtype_rounded,
                          'Blood Type',
                          user.bloodgroup,
                        ),
                        SizedBox(height: 24.h),
                        _buildInfoRow(
                          context,
                          Icons.date_range_rounded,
                          'Enlistment Date',
                          user.enlistment,
                        ),
                        SizedBox(height: 24.h),
                        _buildInfoRow(
                          context,
                          Icons.military_tech_rounded,
                          'ORD',
                          user.ord,
                        ),
                        SizedBox(height: 24.h),
                        _buildInfoRow(
                          context,
                          Icons.star_rounded,
                          'Points',
                          user.points.toString(),
                        ),
                        SizedBox(height: 32.h),
                        SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditSoldierScreen(
                                    userId: user.id,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.edit_document,
                              size: 20.sp,
                              color: Colors.white,
                            ),
                            label: Text(
                              'EDIT SOLDIER DETAILS',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontSize: 14.sp,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? Color.fromARGB(255, 45, 50, 65)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
                spreadRadius: isDarkMode ? 1.r : 0.r,
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 24.sp,
            color: theme.colorScheme.tertiary,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDarkMode 
                      ? Colors.grey[400]
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                  letterSpacing: 1.2,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDarkMode 
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  letterSpacing: 0.5,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
