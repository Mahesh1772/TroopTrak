import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/conduct.dart';
import '../providers/conduct_provider.dart';
import '../../../../features/nominal_roll/presentation/providers/user_detail_provider.dart';
import '../../../../features/nominal_roll/domain/entities/user.dart';
import 'add_conduct_screen.dart';

class ConductDetailsScreen extends StatefulWidget {
  final String conductId;

  const ConductDetailsScreen({
    super.key,
    required this.conductId,
  });

  @override
  State<ConductDetailsScreen> createState() => _ConductDetailsScreenState();
}

class _ConductDetailsScreenState extends State<ConductDetailsScreen> {
  final TextEditingController _participantsSearchController = TextEditingController();
  final TextEditingController _nonParticipantsSearchController = TextEditingController();
  final FocusNode _participantsFocusNode = FocusNode();
  final FocusNode _nonParticipantsFocusNode = FocusNode();
  ValueNotifier<String> _participantsSearchQuery = ValueNotifier<String>('');
  ValueNotifier<String> _nonParticipantsSearchQuery = ValueNotifier<String>('');

  @override
  void dispose() {
    _participantsSearchController.dispose();
    _nonParticipantsSearchController.dispose();
    _participantsFocusNode.dispose();
    _nonParticipantsFocusNode.dispose();
    _participantsSearchQuery.dispose();
    _nonParticipantsSearchQuery.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context, String conductId) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode 
            ? const Color.fromARGB(255, 45, 50, 65) 
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          'Delete Conduct',
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this conduct?',
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.white70 : Colors.black54,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<ConductProvider>().deleteConduct(conductId);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.red[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, {required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? const Color.fromARGB(255, 45, 50, 65) 
            : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 12.sp,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.black.withOpacity(0.2)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  bool rankColorPicker(String rank) {
    return [
      'REC',
      'PTE',
      'LCP',
      'CPL',
      'CFC',
      '3SG',
      '2SG',
      '1SG',
      'SSG',
      'MSG',
      '3WO',
      '2WO',
      '1WO',
      'MWO',
      'SWO',
      'CWO'
    ].contains(rank);
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required ValueNotifier<String> searchQuery,
    required String hintText,
    required bool isDarkMode,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.black.withOpacity(0.2)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) => searchQuery.value = value,
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 14.sp,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white38 : Colors.black38,
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDarkMode ? Colors.white38 : Colors.black38,
              size: 20.sp,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantsSection(BuildContext context, Conduct conductData) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return _buildInfoSection(
      context,
      title: 'Participants',
      children: [
        _buildSearchField(
          controller: _participantsSearchController,
          focusNode: _participantsFocusNode,
          searchQuery: _participantsSearchQuery,
          hintText: 'Search Soldiers',
          isDarkMode: isDarkMode,
        ),
        if (conductData.participants.isEmpty)
          Text(
            'No participants',
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 14.sp,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          ValueListenableBuilder<String>(
            valueListenable: _participantsSearchQuery,
            builder: (context, searchQuery, _) {
              final filteredParticipants = conductData.participants
                  .where((participant) => 
                      participant.toLowerCase().contains(searchQuery.toLowerCase()))
                  .toList();
              
              return Column(
                children: filteredParticipants.map((participant) {
                  return StreamBuilder<User?>(
                    stream: context.read<UserDetailProvider>().getUserByIdUseCase(participant),
                    builder: (context, snapshot) {
                      final rank = snapshot.data?.rank ?? 'REC';
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: theme.colorScheme.secondary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  "lib/assets/army-ranks/${rank.toLowerCase()}.png",
                                  width: 24.w,
                                  height: 24.h,
                                  color: rankColorPicker(rank) ? Colors.white : null,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    participant,
                                    style: GoogleFonts.poppins(
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    rank,
                                    style: GoogleFonts.poppins(
                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                      fontSize: 12.sp,
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
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildNonParticipantsSection(BuildContext context, Conduct conductData) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return _buildInfoSection(
      context,
      title: 'Non-Participants',
      children: [
        _buildSearchField(
          controller: _nonParticipantsSearchController,
          focusNode: _nonParticipantsFocusNode,
          searchQuery: _nonParticipantsSearchQuery,
          hintText: 'Search Non-Participants',
          isDarkMode: isDarkMode,
        ),
        if (conductData.nonParticipants.isEmpty)
          Text(
            'No non-participants',
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 14.sp,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          ValueListenableBuilder<String>(
            valueListenable: _nonParticipantsSearchQuery,
            builder: (context, searchQuery, _) {
              final filteredNonParticipants = conductData.nonParticipants
                  .where((nonParticipant) => 
                      nonParticipant.toLowerCase().contains(searchQuery.toLowerCase()))
                  .toList();
              
              return Column(
                children: filteredNonParticipants.map((nonParticipant) {
                  return StreamBuilder<User?>(
                    stream: context.read<UserDetailProvider>().getUserByIdUseCase(nonParticipant),
                    builder: (context, snapshot) {
                      final rank = snapshot.data?.rank ?? 'REC';
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: Colors.red[400],
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  "lib/assets/army-ranks/${rank.toLowerCase()}.png",
                                  width: 24.w,
                                  height: 24.h,
                                  color: rankColorPicker(rank) ? Colors.white : null,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nonParticipant,
                                    style: GoogleFonts.poppins(
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    rank,
                                    style: GoogleFonts.poppins(
                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6.r),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      conductData.soldierReason[nonParticipant] ?? 'No reason provided',
                                      style: GoogleFonts.poppins(
                                        color: Colors.red[400],
                                        fontSize: 12.sp,
                                        fontStyle: FontStyle.italic,
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
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return StreamBuilder<Conduct>(
      stream: context.read<ConductProvider>().getConductById(widget.conductId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: isDarkMode 
                ? const Color.fromARGB(255, 35, 40, 55) 
                : Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.secondary,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: isDarkMode 
                ? const Color.fromARGB(255, 35, 40, 55) 
                : Colors.white,
            body: Center(
              child: Text(
                'Conduct not found',
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 16.sp,
                ),
              ),
            ),
          );
        }

        final conductData = snapshot.data!;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isDarkMode 
                      ? const Color.fromARGB(255, 35, 40, 55) 
                      : Colors.white,
                  isDarkMode 
                      ? const Color.fromARGB(255, 25, 30, 45) 
                      : Colors.white,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.secondary,
                          theme.colorScheme.secondary.withOpacity(0.9),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conduct Details',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'View and manage conduct information',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12.sp,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddConductScreen(conduct: conductData),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () => _showDeleteDialog(context, conductData.id),
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.delete_rounded,
                                  color: Colors.red[400],
                                  size: 20.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoSection(
                            context,
                            title: 'Conduct Information',
                            children: [
                              _buildInfoRow(context, 'Name', conductData.conductName),
                              _buildInfoRow(context, 'Type', conductData.conductType),
                              _buildInfoRow(context, 'Date', conductData.startDate),
                              _buildInfoRow(context, 'Time', '${conductData.startTime} - ${conductData.endTime}'),
                            ],
                          ),
                          _buildParticipantsSection(context, conductData),
                          _buildNonParticipantsSection(context, conductData),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}