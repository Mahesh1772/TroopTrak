import 'package:flutter/material.dart';
import '../../../domain/entities/user.dart';
import '../user_tile.dart';

class AnimatedUserTile extends StatelessWidget {
  final User user;
  final int index;
  final bool isSearching;

  const AnimatedUserTile({
    super.key,
    required this.user,
    required this.index,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate staggered animation delay based on index
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: isSearching ? 200 : 400),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: UserTile(user: user),
    );
  }
} 