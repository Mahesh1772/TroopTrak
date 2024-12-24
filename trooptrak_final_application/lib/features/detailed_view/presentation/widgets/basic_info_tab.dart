import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../nominal_roll/domain/entities/user.dart';
import '../../../nominal_roll/presentation/providers/user_detail_provider.dart';

class BasicInfoTab extends StatelessWidget {
  final String userId;

  const BasicInfoTab({super.key, required this.userId});

  Widget _buildInfoRow(BuildContext context, String title, String content, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(left: 30.0.w, right: 30.0.w, top: 30.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.tertiary,
            size: 30.sp,
          ),
          SizedBox(width: 20.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                style: theme.textTheme.titleLarge?.copyWith(
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                content.toUpperCase(),
                maxLines: 2,
                style: theme.textTheme.headlineMedium?.copyWith(
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                ),
              );
            }

            final user = snapshot.data;
            if (user == null) {
              return Center(
                child: Text(
                  'User not found',
                  style: theme.textTheme.bodyLarge,
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    context,
                    'Date Of Birth',
                    user.dob,
                    Icons.cake_rounded,
                  ),
                  _buildInfoRow(
                    context,
                    'Ration Type:',
                    user.rationType,
                    Icons.food_bank_rounded,
                  ),
                  _buildInfoRow(
                    context,
                    'Blood Type:',
                    user.bloodgroup,
                    Icons.bloodtype_rounded,
                  ),
                  _buildInfoRow(
                    context,
                    'Enlistment Date:',
                    user.enlistment,
                    Icons.date_range_rounded,
                  ),
                  _buildInfoRow(
                    context,
                    'ORD:',
                    user.ord,
                    Icons.military_tech_rounded,
                  ),
                  SizedBox(height: 30.h),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement edit functionality
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 40.0.w,
                          vertical: 16.0.h,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 72, 30, 229),
                              Color.fromARGB(255, 130, 60, 229),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_note_rounded,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'UPDATE DETAILS',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
