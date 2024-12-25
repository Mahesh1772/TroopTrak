import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// Domain
import '../../domain/entities/user.dart';

// Application
import '../providers/user_provider.dart';

// Presentation
import '../widgets/animations/animated_user_tile.dart';
import 'qr_scanner_page.dart';

// Core
import '../../../../core/theme/theme_manager.dart';

class NominalRollPage extends StatefulWidget {
  const NominalRollPage({super.key});

  @override
  State<NominalRollPage> createState() => _NominalRollPageState();
}

class _NominalRollPageState extends State<NominalRollPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<User> _filteredUsers = [];
  List<User> _allUsers = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _isSearching = true;
        _filterUsers(query);
      });
    });
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      final lowercaseQuery = query.toLowerCase();
      _filteredUsers = _allUsers.where((user) {
        final lowercaseName = user.name.toLowerCase();
        final lowercaseRank = user.rank.toLowerCase();
        return lowercaseName.contains(lowercaseQuery) || 
               lowercaseRank.contains(lowercaseQuery);
      }).toList();
    }
    setState(() {
      _isSearching = false;
    });
  }

  Widget _buildSearchBar(BuildContext context, bool isDarkMode, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.15),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
              spreadRadius: isDarkMode ? 1.r : 2.r,
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search by Name or Rank',
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: isDarkMode ? Colors.white38 : Colors.black38,
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDarkMode ? Colors.white38 : Colors.black38,
              size: 20.sp,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: isDarkMode ? Colors.white38 : Colors.black38,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode, ThemeData theme, ThemeManager themeManager) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, left: 24.w, right: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Nominal Roll',
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 24.sp,
              letterSpacing: 0.5,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          Row(
            children: [
              _buildThemeToggle(isDarkMode, theme, themeManager),
              SizedBox(width: 12.w),
              _buildUserIcon(isDarkMode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(bool isDarkMode, ThemeData theme, ThemeManager themeManager) {
    return Container(
      padding: EdgeInsets.all(8.sp),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? Colors.black.withOpacity(0.3) 
              : Colors.black.withOpacity(0.15),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
            spreadRadius: isDarkMode ? 1.r : 2.r,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          themeManager.toggleTheme(themeManager.themeMode == ThemeMode.light);
        },
        child: Icon(
          themeManager.themeMode == ThemeMode.dark 
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          color: isDarkMode ? Colors.white70 : Colors.black54,
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildUserIcon(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(8.sp),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? Colors.black.withOpacity(0.3) 
              : Colors.black.withOpacity(0.15),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
            spreadRadius: isDarkMode ? 1.r : 2.r,
          ),
        ],
      ),
      child: Image.asset(
        'lib/assets/user.png',
        width: 20.w,
        height: 20.h,
      ),
    );
  }

  Widget _buildUserGrid(BuildContext context) {
    return StreamBuilder<List<User>>(
      stream: context.read<UserProvider>().users,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(context, snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget(context);
        }

        _allUsers = snapshot.data ?? [];
        if (_filteredUsers.isEmpty && !_isSearching) {
          _filteredUsers = List.from(_allUsers);
        }

        if (_filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48.sp,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No soldiers found',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: GridView.builder(
            key: ValueKey<String>(_searchController.text),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              return AnimatedUserTile(
                key: ValueKey(_filteredUsers[index].id),
                user: _filteredUsers[index],
                index: index,
                isSearching: _isSearching,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        'Error: $error',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: CircularProgressIndicator(
        color: theme.colorScheme.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeManager = Provider.of<ThemeManager>(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color.fromARGB(255, 35, 40, 55) : theme.colorScheme.surface,
      floatingActionButton: _buildQRScannerButton(context, theme, isDarkMode),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDarkMode ? const Color.fromARGB(255, 35, 40, 55) : Colors.white,
              isDarkMode ? const Color.fromARGB(255, 25, 30, 45) : Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDarkMode, theme, themeManager),
              SizedBox(height: 20.h),
              _buildSubtitle(context, isDarkMode, theme),
              SizedBox(height: 12.h),
              _buildSearchBar(context, isDarkMode, theme),
              SizedBox(height: 20.h),
              Expanded(
                child: _buildUserGrid(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, bool isDarkMode, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Text(
        'Our Family of Soldiers:',
        style: theme.textTheme.displayMedium?.copyWith(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildQRScannerButton(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary,
            theme.colorScheme.secondary.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withOpacity(isDarkMode ? 0.2 : 0.3),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
            spreadRadius: 2.r,
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () => _showQRScanner(context),
        child: Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.white,
          size: 24.sp,
        ),
      ),
    );
  }

  void _showQRScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => const QRScannerPage(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}
