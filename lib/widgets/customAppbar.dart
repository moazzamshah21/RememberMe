import 'package:flutter/material.dart';
import 'package:rememberme/app/constants/app_colors.dart';

class CustomAppBar extends StatelessWidget {
  final Widget appBarContent;
  final Color backgroundColor;
  
  const CustomAppBar({
    super.key,
    required this.appBarContent,
    this.backgroundColor = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _CustomAppBarDelegate(
        appBarContent: appBarContent,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _CustomAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget appBarContent;
  final Color backgroundColor;

  _CustomAppBarDelegate({
    required this.appBarContent,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isCollapsed = shrinkOffset > maxExtent - minExtent;
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(60),
          bottomRight: Radius.circular(60),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlackMedium,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: isCollapsed ? 60 : 30,
          left: 40,
          right: 40,
          bottom: isCollapsed ? 30 : 30,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isCollapsed
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remember Me',
                      style: TextStyle(
                        color: AppColors.primaryTealAlt,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'PolySans',
                      ),
                    ),
                  ],
                )
              : appBarContent,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 150.0;

  @override
  double get minExtent => 150.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}